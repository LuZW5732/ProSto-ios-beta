using System;
using System.Diagnostics;
using System.IO;

internal static class SyncLauncher
{
    private static int Main(string[] args)
    {
        string build = AppDomain.CurrentDomain.BaseDirectory;
        string log = Path.Combine(build, "vm-sync.log");
        try
        {
            if (args.Length != 1 || !File.Exists(args[0]))
                throw new ArgumentException("The Git for Windows Bash executable was not found.");

            var start = new ProcessStartInfo(args[0],
                "-c \"exec /bin/bash Tools/ios-vm-host.sh sync > build/vm-sync.log 2>&1\"")
            {
                WorkingDirectory = Path.GetFullPath(Path.Combine(build, "..")),
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardInput = true
            };
            using (var process = Process.Start(start))
            {
                process.StandardInput.Close();
                process.WaitForExit();
                return process.ExitCode;
            }
        }
        catch (Exception error)
        {
            File.WriteAllText(log, error.Message + Environment.NewLine);
            return 1;
        }
    }
}
