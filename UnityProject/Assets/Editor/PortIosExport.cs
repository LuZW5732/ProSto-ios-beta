using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;

public static class PortIosExport
{
#if UNITY_IOS
    [UnityEditor.Callbacks.PostProcessBuild(100)]
    public static void EnableSaveFileSharing(BuildTarget target, string exportPath)
    {
        if (target != BuildTarget.iOS) return;

        var path = Path.Combine(exportPath, "Info.plist");
        var plist = new UnityEditor.iOS.Xcode.PlistDocument();
        plist.ReadFromFile(path);
        plist.root.SetBoolean("UIFileSharingEnabled", true);
        plist.root.SetBoolean("LSSupportsOpeningDocumentsInPlace", true);
        plist.WriteToFile(path);

        const string launcher = "Classes/PSLauncher.mm";
        File.Copy(Path.Combine(UnityEngine.Application.dataPath, "Editor/PSLauncher.mm.txt"),
            Path.Combine(exportPath, launcher), overwrite: true);
        var projectPath = UnityEditor.iOS.Xcode.PBXProject.GetPBXProjectPath(exportPath);
        var project = new UnityEditor.iOS.Xcode.PBXProject();
        project.ReadFromFile(projectPath);
        var file = project.FindFileGuidByProjectPath(launcher);
        if (string.IsNullOrEmpty(file))
        {
            file = project.AddFile(launcher, launcher, UnityEditor.iOS.Xcode.PBXSourceTree.Source);
            project.AddFileToBuildWithFlags(project.GetUnityFrameworkTargetGuid(), file, "-fobjc-arc");
        }
        project.WriteToFile(projectPath);
    }
#endif

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
