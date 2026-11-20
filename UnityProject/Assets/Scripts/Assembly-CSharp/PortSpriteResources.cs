using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public sealed class PortSpriteResources : ScriptableObject
{
    [Serializable]
    public sealed class Entry { public string path; public Sprite sprite; }
    public Entry[] entries;
    private static PortSpriteResources instance;
    private static readonly Dictionary<string, Sprite[]> cache = new Dictionary<string, Sprite[]>(StringComparer.OrdinalIgnoreCase);

    public static Sprite[] LoadAll(string path)
    {
        if (path == null) throw new ArgumentNullException(nameof(path));
        path = path.Replace('\\', '/').Trim('/');
        if (cache.TryGetValue(path, out var result)) return result;
        if (instance == null) instance = Resources.Load<PortSpriteResources>("PortSpriteResources");
        if (instance == null) throw new InvalidOperationException("Missing recovered sprite resource index");
        result = instance.entries.Where(e => e.sprite != null && (path.Length == 0 ||
            string.Equals(e.path, path, StringComparison.OrdinalIgnoreCase) || e.path.StartsWith(path + "/", StringComparison.OrdinalIgnoreCase)))
            .Select(e => e.sprite).Distinct().ToArray();
        if (result.Length == 0) result = Resources.LoadAll<Sprite>(path);
        cache[path] = result;
        return result;
    }
    public static Sprite Load(string path)
    {
        if (path == null) throw new ArgumentNullException(nameof(path));
        path = path.Replace('\\', '/').Trim('/');
        if (instance == null) instance = Resources.Load<PortSpriteResources>("PortSpriteResources");
        if (instance == null) throw new InvalidOperationException("Missing recovered sprite resource index");
        var entry = instance.entries.FirstOrDefault(e => e.sprite != null && string.Equals(e.path, path, StringComparison.OrdinalIgnoreCase));
        return entry != null ? entry.sprite : Resources.Load<Sprite>(path);
    }
}
