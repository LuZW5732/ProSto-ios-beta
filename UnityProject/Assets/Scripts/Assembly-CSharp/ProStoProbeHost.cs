#if PROSTO_DYNAMIC_MOD_PROBE
using System;
using System.IO;
using System.Reflection;

// Compiled separately from the probe. The host has no assembly reference to it.
public static class ProStoProbeHost
{
    public static string Run(string path)
    {
        var assembly = Assembly.Load(File.ReadAllBytes(path));
        var method = assembly.GetType("ProStoModProbe", true).GetMethod("QuerySlot",
            BindingFlags.Public | BindingFlags.Static, null, new[] { typeof(int) }, null);
        if (method == null || method.ReturnType != typeof(string))
            throw new MissingMethodException("ProStoModProbe.QuerySlot(int)");
        var result = (string)method.Invoke(null, new object[] { 37 });
        if (result != "save_37.es3") throw new InvalidDataException("Unexpected slot name: " + result);
        return result;
    }
}

#if UNITY_IOS && !UNITY_EDITOR
internal static class ProStoIosProbe
{
    [System.Runtime.InteropServices.DllImport("__Internal")]
    private static extern int PSLauncherProbeEnabled();

    [UnityEngine.RuntimeInitializeOnLoadMethod(UnityEngine.RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void Run()
    {
        string folder = Path.Combine(UnityEngine.Application.persistentDataPath, "ModProbe");
        System.IO.Directory.CreateDirectory(folder);
        string input = Path.Combine(folder, "ProStoModProbe.dll");
        string status;
        try
        {
            string imported = Path.Combine(UnityEngine.Application.persistentDataPath, "ImportedMods", "ProStoModProbe.dll");
            if (File.Exists(imported))
            {
                if (PSLauncherProbeEnabled() == 0)
                {
                    File.WriteAllText(Path.Combine(folder, "result.txt"), "Disabled in launcher");
                    return;
                }
                input = imported;
            }
            status = File.Exists(input) ? "PASS " + ProStoProbeHost.Run(input) : "Waiting for ProStoModProbe.dll";
        }
        catch (Exception error)
        {
            status = "FAIL " + error;
        }
        File.WriteAllText(Path.Combine(folder, "result.txt"), status);
    }
}
#endif
#endif