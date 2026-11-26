using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

try { Generate(args); }
catch (Exception error) { Console.Error.WriteLine(error.ToString()); Environment.ExitCode = 1; }

static void Generate(string[] args)
{
if (args.Length is < 2 or > 3)
    throw new ArgumentException("Usage: StaticHookGenerator <source-root> <report.json> [external-targets.json]");
var root = Path.GetFullPath(args[0]);
var reportPath = Path.GetFullPath(args[1]);
var externalPath = args.Length == 3
    ? Path.GetFullPath(args[2])
    : Path.Combine(Path.GetDirectoryName(reportPath)!, "external-hook-targets.json");
if (!File.Exists(externalPath))
    throw new FileNotFoundException("Pass the external target manifest as the third argument if it is not beside the report.", externalPath);
var externalTargets = JsonSerializer.Deserialize<ExternalTarget[]>(File.ReadAllText(externalPath),
    new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
if (externalTargets == null || externalTargets.Any(target => target == null
    || string.IsNullOrWhiteSpace(target.Type)
    || string.IsNullOrWhiteSpace(target.Method)
    || string.IsNullOrWhiteSpace(target.ReturnType)
    || target.Parameters == null || target.Parameters.Any(string.IsNullOrWhiteSpace)))
    throw new InvalidDataException($"Invalid external target manifest: {externalPath}");
var externalTargetsByName = externalTargets.ToLookup(target => (target.Type, target.Method));
var targets = new HashSet<(string Type, string Name)>();
foreach (var path in Directory.GetFiles(Path.Combine(root, "PortMods"), "*.cs", SearchOption.AllDirectories))
{
    var text = File.ReadAllText(path);
    foreach (Match match in Regex.Matches(text, "PortReflection\\.Method\\(typeof\\((\\w+)\\),\\s*(?:\"(\\w+)\"|nameof\\(\\w+\\.(\\w+)\\))"))
        targets.Add((match.Groups[1].Value, match.Groups[2].Success ? match.Groups[2].Value : match.Groups[3].Value));
}
foreach (var name in new[] { "OnEventInit", "TriggerButton", "OnEventReset", "TryOpenSortMenu" }) targets.Add(("ItemContextHandler", name));
foreach (var name in new[] { "AddProgressBarOld", "AddProgressTest" }) targets.Add(("RichTextBuilder", name));
// This is reflected for invoking a config setter, never registered as a patch target.
targets.Remove(("ConfigEntry", "ApplyBoxed"));
var report = new List<object>();
var writes = new List<(string Path, string Text)>();
foreach (var file in Directory.GetFiles(root, "*.cs", SearchOption.TopDirectoryOnly).OrderBy(Path.GetFileName, StringComparer.Ordinal))
{
    var text = File.ReadAllText(file);
    var tree = CSharpSyntaxTree.ParseText(text);
    var syntax = tree.GetCompilationUnitRoot();
    var replacements = new List<(int Start, int Length, string Text)>();
    int index = Regex.Matches(text, "__portHook(\\d+)").Select(m => int.Parse(m.Groups[1].Value)).DefaultIfEmpty(-1).Max() + 1;
    foreach (var method in syntax.DescendantNodes().OfType<MethodDeclarationSyntax>())
    {
        var type = method.Parent as ClassDeclarationSyntax;
        if (type == null) continue;
        var target = (type.Identifier.Text, method.Identifier.Text);
        var externalCandidates = externalTargetsByName[target];
        bool hasExternalCandidates = externalCandidates.Any();
        if (!hasExternalCandidates && !targets.Contains(target)) continue;
        var parameters = method.ParameterList.Parameters;
        bool hasByRefParameters = parameters.Any(p => p.Modifiers.Any(m => m.IsKind(SyntaxKind.RefKeyword) || m.IsKind(SyntaxKind.OutKeyword) || m.IsKind(SyntaxKind.InKeyword)));
        bool hasTypeParameters = method.TypeParameterList != null || type.TypeParameterList != null;
        var resultType = method.ReturnType.ToString();
        bool isVoid = resultType == "void";
        bool isStatic = method.Modifiers.Any(SyntaxKind.StaticKeyword);
        bool hasImplementation = method.Body != null || method.ExpressionBody != null;
        var parameterTypes = parameters.Select(p => p.Type.ToString()).ToArray();
        bool isExternalMatch = false;
        foreach (var externalTarget in externalCandidates)
        {
            if (hasByRefParameters || hasTypeParameters || isStatic != externalTarget.IsStatic
                || resultType != externalTarget.ReturnType || !parameterTypes.SequenceEqual(externalTarget.Parameters)) continue;
            if (isExternalMatch)
                throw new InvalidDataException($"Duplicate external hook target {externalTarget.Signature}.");
            externalTarget.Matches++;
            isExternalMatch = true;
            if (!hasImplementation)
                throw new InvalidOperationException($"Required hook target {externalTarget.Signature} must have a body.");
        }
        if (hasExternalCandidates && !isExternalMatch) continue;
        if (method.AttributeLists.ToString().Contains("StaticHookTarget"))
        {
            report.Add(new { file = Path.GetFileName(file), type = type.Identifier.Text, method = method.Identifier.Text,
                parameters = parameterTypes });
            continue;
        }
        if (!hasImplementation) continue;
        if (hasTypeParameters || hasByRefParameters)
            throw new NotSupportedException("Review ref/generic target explicitly: " + type.Identifier + "." + method.Identifier);
        var name = method.Identifier.Text;
        var id = "__portHook" + index++;
        var instance = isStatic ? "null" : "this";
        string signature = string.Join(", ", parameters.Select(p => "typeof(" + p.Type + ")"));
        string argumentValues = string.Join(", ", parameters.Select(p => p.Identifier.Text));
        string assignments = string.Join("\n", parameters.Select((p, i) => p.Identifier.Text + " = (" + p.Type + ")__portArguments[" + i + "];"));
        var original = method.Body?.ToString() ?? "{ " + (isVoid ? "" : "return ") + method.ExpressionBody.Expression + "; }";
        string call = isVoid ? "__PortOriginal(); return null;" : "return __PortOriginal();";
        string fast = isVoid ? "__PortOriginal(); return;" : "return __PortOriginal();";
        var body = CSharpSyntaxFactory.ParseStatement($$"""
        {
            if (!ProbablyStolen.Port.Mods.StaticModHooks.HasHooks({{id}})) { {{fast}} }
            {{(isVoid ? "" : "return ")}}ProbablyStolen.Port.Mods.StaticModHooks.Invoke<{{(isVoid ? "object" : resultType)}}>(
                {{id}}, {{instance}}, new object[] { {{argumentValues}} }, __portArguments => {
                    {{assignments}}
                    {{call}}
                });
            {{resultType}} __PortOriginal() {{original}}
        }
        """) as BlockSyntax;
        var wrapped = method.WithBody(body).WithExpressionBody(null).WithSemicolonToken(default)
            .AddAttributeLists(SyntaxFactory.AttributeList(SyntaxFactory.SingletonSeparatedList(
                SyntaxFactory.Attribute(SyntaxFactory.ParseName("ProbablyStolen.Port.Mods.StaticHookTarget")))))
            .NormalizeWhitespace().ToFullString();
        var field = $"private static readonly System.Reflection.MethodInfo {id} = ProbablyStolen.Port.Mods.PortReflection.Method(typeof({type.Identifier}), \"{name}\", new System.Type[] {{ {signature} }});\n";
        replacements.Add((method.SpanStart, method.Span.Length, field + wrapped));
        report.Add(new { file = Path.GetFileName(file), type = type.Identifier.Text, method = name, parameters = parameterTypes });
    }
    foreach (var change in replacements.OrderByDescending(r => r.Start)) text = text.Remove(change.Start, change.Length).Insert(change.Start, change.Text);
    if (replacements.Count > 0) writes.Add((file, text));
}
foreach (var target in externalTargets)
    if (target.Matches != 1)
        throw new InvalidOperationException($"Expected exactly one required hook target {target.Signature}, found {target.Matches}.");
foreach (var write in writes) File.WriteAllText(write.Path, write.Text);
File.WriteAllText(reportPath, JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine($"Generated {report.Count} explicit callback entries.");
}

sealed class ExternalTarget
{
    public required string Type { get; init; }
    public required string Method { get; init; }
    public required string[] Parameters { get; init; }
    public required bool IsStatic { get; init; }
    public required string ReturnType { get; init; }
    internal int Matches { get; set; }
    internal string Signature => $"{(IsStatic ? "static" : "instance")} {ReturnType} {Type}.{Method}({string.Join(", ", Parameters)})";
}

static class CSharpSyntaxFactory
{
    internal static StatementSyntax ParseStatement(string text) => SyntaxFactory.ParseStatement(text);
}
