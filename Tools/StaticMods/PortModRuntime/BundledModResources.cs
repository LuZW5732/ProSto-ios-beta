using System;
using System.IO;
using UnityEngine;

namespace ProbablyStolen.Port.Mods
{
    internal static class BundledModResources
    {
        internal static Stream Open(string name)
        {
            if (name != "SmartInventoryArrange/directional21") throw new ArgumentException("Unknown bundled model.");
            return File.OpenRead(Path.Combine(Application.streamingAssetsPath, "PortMods", name + ".json"));
        }
    }
}
