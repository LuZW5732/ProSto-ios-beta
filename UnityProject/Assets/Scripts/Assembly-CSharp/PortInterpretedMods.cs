using System;
using System.IO;
using System.Linq;
using System.Reflection;

internal static class PortInterpretedMods
{
    internal static string UnavailableReason(ModManifest manifest)
    {
#if PROSTO_INTERP
        if (manifest.Assemblies.Count != 1) return "当前免 JIT 加载器支持单 DLL 模组。";
        if (manifest.Prerequisites.Count != 0) return "当前免 JIT 加载器尚未接入前置模组：" + string.Join(", ", manifest.Prerequisites);
        if (manifest.Capabilities.Count != 0) return "当前免 JIT 加载器尚未接入权限授权：" + string.Join(", ", manifest.Capabilities);
        return null;
#else
        return "已识别外部模组。此构建未集成解释器。";
#endif
    }

#if PROSTO_INTERP
    private static bool metadataLoaded;
    private const int DiagnosticLimit = 128 * 1024;
    private static string diagnosticPath;
    private static long diagnosticBytes;

#if UNITY_IOS && !UNITY_EDITOR
    private enum RuntimePreference { Automatic = 0, Interpreter = 1, Jit = 2 }
    private enum JitMemoryStatus { NotChecked = 0, Mapped = 1, Unavailable = 2, Unsupported = 3 }

    [System.Runtime.InteropServices.DllImport("__Internal")]
    private static extern void PSLauncherReadRuntimeStatus(out RuntimePreference preference,
        out JitMemoryStatus memoryStatus, out int error);
#endif

    [UnityEngine.RuntimeInitializeOnLoadMethod(UnityEngine.RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void StartDiagnostics()
    {
        string directory = UnityEngine.Application.persistentDataPath;
        if (!File.Exists(Path.Combine(directory, "port-mod-diagnostics.enable"))) return;
        string path = Path.Combine(directory, "port-mod-diagnostics.txt");
        try
        {
            File.WriteAllText(path, "iOS mod diagnostics\n");
            diagnosticPath = path;
            diagnosticBytes = new FileInfo(path).Length;
            UnityEngine.Application.logMessageReceived += RecordDiagnostic;
#if UNITY_IOS && !UNITY_EDITOR
            PSLauncherReadRuntimeStatus(out var preference, out var memoryStatus, out int error);
            Trace($"runtime=HybridCLR; preferred={preference}; jitMemory={memoryStatus}; errno={error}");
#endif
        }
        catch (IOException error) { UnityEngine.Debug.LogWarning(error.Message); }
        catch (UnauthorizedAccessException error) { UnityEngine.Debug.LogWarning(error.Message); }
    }

    internal static void Trace(string message)
    {
        if (diagnosticPath != null) UnityEngine.Debug.Log("[PortMods] " + message);
    }

    private static void RecordDiagnostic(string message, string stack, UnityEngine.LogType type)
    {
        bool error = type == UnityEngine.LogType.Error || type == UnityEngine.LogType.Exception ||
            type == UnityEngine.LogType.Assert;
        if (!error && !message.StartsWith("[PortMods] ", StringComparison.Ordinal)) return;
        string line = $"{DateTime.UtcNow:O} {type} {message}\n";
        if (error && !string.IsNullOrEmpty(stack)) line += stack + "\n";
        int size = System.Text.Encoding.UTF8.GetByteCount(line);
        if (size > DiagnosticLimit - diagnosticBytes) return;
        try
        {
            File.AppendAllText(diagnosticPath, line);
            diagnosticBytes += size;
        }
        catch (IOException) { UnityEngine.Application.logMessageReceived -= RecordDiagnostic; }
        catch (UnauthorizedAccessException) { UnityEngine.Application.logMessageReceived -= RecordDiagnostic; }
    }

    private static void LoadMetadata()
    {
        if (metadataLoaded) return;
        string metadata = Path.Combine(UnityEngine.Application.streamingAssetsPath, "PortInterpreterMetadata");
        foreach (var file in System.IO.Directory.GetFiles(metadata, "*.bytes"))
        {
            var code = HybridCLR.RuntimeApi.LoadMetadataForAOTAssembly(File.ReadAllBytes(file),
                HybridCLR.HomologousImageMode.SuperSet);
            Trace("AOT metadata " + Path.GetFileName(file) + ": " + code);
            if (code != HybridCLR.LoadImageErrorCode.OK && code != HybridCLR.LoadImageErrorCode.HOMOLOGOUS_ASSEMBLY_HAS_LOADED)
                throw new InvalidDataException(Path.GetFileName(file) + ": " + code);
        }
        metadataLoaded = true;
    }

    internal static IMod LoadEntry(LoadedMod mod)
    {
        var path = Path.Combine(mod.FolderPath, mod.Manifest.Assemblies.Single());
        var bytes = File.ReadAllBytes(path);
        using (var stream = new MemoryStream(bytes, false))
        using (var module = DseCecil.ModuleDefinition.ReadModule(stream))
        {
            if (module.Assembly == null || (module.Attributes & DseCecil.ModuleAttributes.ILOnly) == 0)
                throw new NotSupportedException("需要纯托管的 .NET 模组 DLL。");
            mod.ManagesHarmonyPatches = PortHarmonyHooks.ValidateImage(module);
            string name = module.Assembly.Name.Name;
            if (ModLoader.IsGameAssemblyName(name) || AppDomain.CurrentDomain.GetAssemblies().Any(a =>
                    string.Equals(a.GetName().Name, name, StringComparison.OrdinalIgnoreCase)))
                throw new InvalidDataException("程序集名称已被占用：" + name);
        }
        var scan = ModScanner.ScanLocalImage(path, bytes, mod.FolderPath);
        mod.LastScan = scan;
        if (scan.Refused) throw new InvalidDataException(scan.Error ?? scan.FormatFindings());
        if (scan.Capabilities.Count != 0)
            throw new NotSupportedException("模组使用额外权限：" + string.Join(", ", scan.Capabilities));

        mod.DllPath = path;
        mod.Assembly = Assembly.Load(bytes);
        var entries = mod.Assembly.GetTypes().Where(t => typeof(IMod).IsAssignableFrom(t)
            && !t.IsInterface && !t.IsAbstract && !t.ContainsGenericParameters).ToArray();
        if (entries.Length != 1) throw new InvalidDataException($"需要一个具体的 IMod 入口，实际找到 {entries.Length} 个。");
        return (IMod)Activator.CreateInstance(entries[0]);
    }

    internal static void RemoveHooks(LoadedMod mod) => PortHarmonyHooks.Remove(mod);

    internal static void Stop(LoadedMod mod)
    {
        if (!mod.ManagesHarmonyPatches) RemoveHooks(mod);
        try { mod.Instance?.OnDisable(); }
        catch (Exception error) { UnityEngine.Debug.LogException(error); }
        finally
        {
            if (mod.ManagesHarmonyPatches) RemoveHooks(mod);
            mod.Instance = null;
            mod.IsEnabled = false;
        }
    }

    internal static void Start(LoadedMod mod)
    {
        Trace(mod.Manifest.ID + ": loading " + mod.Manifest.ModVersion);
#if !UNITY_EDITOR
        LoadMetadata();
#endif
        mod.Instance = LoadEntry(mod);
        try
        {
            PortHarmonyHooks.Register(mod);
            Trace(mod.Manifest.ID + ": Init (manual Harmony: " + mod.ManagesHarmonyPatches + ")");
            mod.Instance.Init(mod.Manifest);
            mod.IsEnabled = true;
            mod.Instance.OnEnable();
            Trace(mod.Manifest.ID + ": OnEnable finished");
        }
        catch
        {
            Stop(mod);
            throw;
        }
    }
#endif
}
