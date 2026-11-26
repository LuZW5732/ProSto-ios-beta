using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

try { Generate(args); }
catch (Exception error) { Console.Error.WriteLine(error.ToString()); Environment.ExitCode = 1; }

static void Generate(string[] args)
{
var root = Path.GetFullPath(args[0]);
var targets = new HashSet<(string Type, string Name)>();
foreach (var path in Directory.GetFiles(Path.Combine(root, "PortMods"), "*.cs", SearchOption.AllDirectories))
{
    var text = File.ReadAllText(path);
    foreach (Match match in Regex.Matches(text, "PortReflection\\.Method\\(typeof\\((\\w+)\\),\\s*(?:\"(\\w+)\"|nameof\\(\\w+\\.(\\w+)\\))"))
        targets.Add((match.Groups[1].Value, match.Groups[2].Success ? match.Groups[2].Value : match.Groups[3].Value));
}
foreach (var name in new[] { "OnEventInit", "TriggerButton", "OnEventReset", "TryOpenSortMenu" }) targets.Add(("ItemContextHandler", name));
foreach (var name in new[] { "AddProgressBarOld", "AddProgressTest" }) targets.Add(("RichTextBuilder", name));
var tradeHook = (Type: "StoreReputation", Name: "OnItemTraded");
string[] tradeHookParameters = ["string", "int", "int", "StoreClient", "bool", "GameItem"];
var tradeHookSignature = $"static void {tradeHook.Type}.{tradeHook.Name}({string.Join(", ", tradeHookParameters)})";
int tradeHookMatches = 0;
targets.Add(tradeHook);
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
        if (!targets.Contains(target)) continue;
        var parameters = method.ParameterList.Parameters;
        bool hasByRefParameters = parameters.Any(p => p.Modifiers.Any(m => m.IsKind(SyntaxKind.RefKeyword) || m.IsKind(SyntaxKind.OutKeyword) || m.IsKind(SyntaxKind.InKeyword)));
        bool hasTypeParameters = method.TypeParameterList != null || type.TypeParameterList != null;
        var resultType = method.ReturnType.ToString();
        bool isVoid = resultType == "void";
        bool isStatic = method.Modifiers.Any(SyntaxKind.StaticKeyword);
        bool hasImplementation = method.Body != null || method.ExpressionBody != null;
        if (target == tradeHook)
        {
            if (hasByRefParameters || hasTypeParameters || !isStatic || !isVoid
                || !parameters.Select(p => p.Type.ToString()).SequenceEqual(tradeHookParameters)) continue;
            tradeHookMatches++;
            if (!hasImplementation)
                throw new InvalidOperationException($"Required hook target {tradeHookSignature} must have a body.");
        }
        if (method.AttributeLists.ToString().Contains("StaticHookTarget"))
        {
            report.Add(new { file = Path.GetFileName(file), type = type.Identifier.Text, method = method.Identifier.Text,
                parameters = method.ParameterList.Parameters.Select(p => p.Type.ToString()).ToArray() });
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
        report.Add(new { file = Path.GetFileName(file), type = type.Identifier.Text, method = name, parameters = parameters.Select(p => p.Type.ToString()).ToArray() });
    }
    foreach (var change in replacements.OrderByDescending(r => r.Start)) text = text.Remove(change.Start, change.Length).Insert(change.Start, change.Text);
    if (replacements.Count > 0) writes.Add((file, text));
}
if (tradeHookMatches != 1)
    throw new InvalidOperationException($"Expected exactly one required hook target {tradeHookSignature}, found {tradeHookMatches}.");
foreach (var write in writes) File.WriteAllText(write.Path, write.Text);
File.WriteAllText(args[1], JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine($"Generated {report.Count} explicit callback entries.");
}

static class CSharpSyntaxFactory
{
    internal static StatementSyntax ParseStatement(string text) => SyntaxFactory.ParseStatement(text);
}
