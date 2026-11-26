using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using Dir = System.IO.Directory;

internal static class PortModPackages
{
    internal static ModManifest Read(string folder)
    {
        var manifest = ModLoader.ParseManifestForTools(folder, out var error);
        if (manifest == null) throw new InvalidDataException(error);
        foreach (var dll in manifest.Assemblies)
            if (!File.Exists(Path.Combine(folder, dll))) throw new InvalidDataException("缺少 " + dll);
        return manifest;
    }

    internal static string Install(string zip, string mods, Func<string, bool> reserved)
    {
        Dir.CreateDirectory(mods);
        var stage = Path.Combine(mods, ".import-" + Guid.NewGuid().ToString("N"));
        Dir.CreateDirectory(stage);
        try
        {
            using (var archive = ZipFile.OpenRead(zip))
            {
                if (archive.Entries.Count > 4096) throw new InvalidDataException("压缩包文件过多");
                long remaining = 256L * 1024 * 1024;
                var buffer = new byte[65536];
                foreach (var entry in archive.Entries)
                {
                    var parts = entry.FullName.Replace('\\', '/').TrimEnd('/').Split('/');
                    if (parts.Any(s => s == "" || s == "." || s == ".." || s.Contains(":")))
                        throw new InvalidDataException("压缩包包含无效路径");
                    if (parts[0] == "__MACOSX" || parts.Any(s => s.StartsWith("._"))) continue;
                    var path = Path.Combine(stage, string.Join("/", parts));
                    if (entry.FullName.EndsWith("/") || entry.FullName.EndsWith("\\"))
                    {
                        Dir.CreateDirectory(path);
                        continue;
                    }
                    Dir.CreateDirectory(Path.GetDirectoryName(path));
                    using var src = entry.Open();
                    using var dst = new FileStream(path, FileMode.CreateNew);
                    int n;
                    while ((n = src.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        if ((remaining -= n) < 0) throw new InvalidDataException("解压大小超过 256 MiB");
                        dst.Write(buffer, 0, n);
                    }
                }
            }
            var manifests = Dir.GetFiles(stage, "manifest.xml", SearchOption.AllDirectories);
            if (manifests.Length != 1) throw new InvalidDataException("每个 ZIP 需要一份 manifest.xml");
            var root = Path.GetDirectoryName(manifests[0]);
            var id = Read(root).ID;
            var dest = Path.Combine(mods, id);
            if (reserved(id) || Dir.Exists(dest)) throw new IOException("已存在同 ID 模组：" + id);
            Dir.Move(root, dest);
            return id;
        }
        finally { if (Dir.Exists(stage)) Dir.Delete(stage, true); }
    }

    internal static void Discover(string docs, List<LoadedMod> mods)
    {
        string root = Path.Combine(docs, "Mods"), inbox = Path.Combine(docs, "ModImports");
        Dir.CreateDirectory(root);
        var ids = new HashSet<string>(mods.Select(m => m.Manifest.ID), StringComparer.OrdinalIgnoreCase);
        void Scan(string folder)
        {
            var m = Read(folder);
            if (!ids.Add(m.ID)) throw new InvalidDataException("重复的模组 ID：" + m.ID);
            mods.Add(new LoadedMod { Manifest = m, FolderPath = folder, Source = ModSource.Local,
                LoadError = PortInterpretedMods.UnavailableReason(m) });
        }
        Action<string> report = msg => UnityEngine.Debug.LogWarning("[ModImport] " + msg);
        foreach (var folder in Dir.GetDirectories(root).OrderBy(s => s, StringComparer.Ordinal))
        {
            if (Path.GetFileName(folder).StartsWith(".")) continue;
            try { Scan(folder); } catch (Exception e) { report(e.Message); }
        }
        if (!Dir.Exists(inbox)) return;
        var messages = new List<string>();
        foreach (var zip in Dir.GetFiles(inbox).Where(p => p.EndsWith(".zip", StringComparison.OrdinalIgnoreCase)))
        {
            try
            {
                var id = Install(zip, root, ids.Contains);
                Scan(Path.Combine(root, id));
                File.Delete(zip);
                messages.Add("已导入 " + id);
            }
            catch (Exception e) { messages.Add(Path.GetFileName(zip) + "：" + e.Message); report(e.Message); }
        }
        if (messages.Count > 0) File.WriteAllLines(Path.Combine(inbox, "result.txt"), messages);
    }
}
