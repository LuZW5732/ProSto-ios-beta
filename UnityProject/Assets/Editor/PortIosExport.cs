using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;

public static class PortIosExport
{
    public static void Run()
    {
        var exportPath = Environment.GetEnvironmentVariable("PORT_IOS_EXPORT_PATH");
        if (string.IsNullOrEmpty(exportPath) || !Path.IsPathRooted(exportPath))
            throw new BuildFailedException("PORT_IOS_EXPORT_PATH must be an absolute path.");

        var scenes = EditorBuildSettings.scenes.Where(scene => scene.enabled)
            .Select(scene => scene.path).ToArray();
        if (scenes.Length == 0)
            throw new BuildFailedException("No enabled scenes in Unity Build Settings.");

        var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
        {
            scenes = scenes,
            target = BuildTarget.iOS,
            locationPathName = exportPath,
            options = BuildOptions.None
        });
        if (report.summary.result != BuildResult.Succeeded)
            throw new BuildFailedException($"iOS export {report.summary.result} ({report.summary.totalErrors} errors).");
    }
}
