"""Isolate the existing desktop loader at compile time; register only bundled sources on iOS."""
from pathlib import Path
import re
from prepare_static_mods import mask

ROOT=Path(__file__).resolve().parent
PROJECT=ROOT/'local/cloud-repo/UnityProject'
SRC=PROJECT/'Assets/Scripts/Assembly-CSharp'

def method(text,name,ios):
    m=re.search(r'^\s*(?:public|private|internal|protected)\s+[^\n=;]+\b'+name+r'\([^;]*?\)\s*\{',mask(text),re.M)
    if not m:raise ValueError(name)
    start=text.index('{',m.start());end=start+1;depth=1;s=mask(text)
    while depth:
        if s[end]=='{':depth+=1
        elif s[end]=='}':depth-=1
        end+=1
    return text[:start+1]+'\n#if UNITY_IOS\n'+ios+'\n#else\n'+text[start+1:end-1]+'\n#endif\n'+text[end-1:]

def main():
    p=SRC/'ModLoader.cs';s=p.read_text(encoding='utf-8-sig')
    if '// PORT_BUNDLED_HOST' in s:raise SystemExit('Host already prepared; do not reapply.')
    s=s.replace('using HarmonyLib;', '#if !UNITY_IOS\nusing HarmonyLib;\n#endif\nusing ProbablyStolen.Port.Mods;\n// PORT_BUNDLED_HOST')
    s=re.sub(r'(\tprivate static readonly Dictionary<string, Harmony>[^\n]+)',r'#if !UNITY_IOS\n\1\n#endif',s)
    s=method(s,'TranspilingModOf','return null; // No emitted replacement methods in the static iOS loader.')
    s=method(s,'Awake','''
        if (Instance != null) { UnityEngine.Object.Destroy(gameObject); return; }
        Instance = this;
        UnityEngine.Object.DontDestroyOnLoad(gameObject);
        LoadModOrder();
        var bundled = BundledModCatalog.Create();
        mods.AddRange(bundled);
        if (!ES3.KeyExists("portBundledDefaultsV1"))
        {
            foreach (var mod in bundled)
                if (EnabledMods.Add(mod.Manifest.ID)) _modOrder.Add(mod.Manifest.ID);
            ES3.Save("modOrder", _modOrder);
            ES3.Save("portBundledDefaultsV1", true);
        }
        ApplySavedOrder();
        foreach (var mod in bundled) LoadLocalization(mod);
        foreach (var mod in mods) BundledModCatalog.Initialize(mod, EnabledMods.Contains(mod.Manifest.ID));
''')
    s=method(s,'Update','if (Instance == this) ModHelper.DrainMainThread();')
    s=method(s,'SetModEnabled','''
        if (!BundledModCatalog.Contains(id)) throw new PlatformNotSupportedException("This build supports bundled mods only.");
        if (enabled) { if (EnabledMods.Add(id)) _modOrder.Add(id); }
        else { EnabledMods.Remove(id); _modOrder.Remove(id); }
        ES3.Save("modOrder", _modOrder);
        RestartRequired = true; // Let active solver/coroutine work finish; apply at restart.
''')
    s=method(s,'CheckEnable','''return new ModEnableCheck { Mod = mod,
        Refusal = mod != null && mod.Source == ModSource.Bundled && BundledModCatalog.Contains(mod.Manifest.ID)
            ? null : "This iOS build supports its bundled mods only." };''')
    s=method(s,'ApproveAndEnable','''if (check == null || check.Mod != mod || check.Refusal != null || mod.Source != ModSource.Bundled)
            throw new InvalidOperationException("Invalid bundled mod enable request.");
        SetModEnabled(mod.Manifest.ID, true);''')
    s=method(s,'SetDeveloperMode','throw new PlatformNotSupportedException("External DLL mods are not supported on iOS.");')
    s=method(s,'ResolveModDependency','throw new PlatformNotSupportedException("Dynamic assemblies are not supported on iOS.");')
    s=method(s,'ReapplyListVerdicts','return; // No external mods were loaded by this build.')
    s=method(s,'StopRunningMod','''if (mod.Source != ModSource.Bundled) throw new PlatformNotSupportedException();
        BundledModCatalog.Stop(mod); RestartRequired = true;''')
    s=method(s,'LoadModDll','throw new PlatformNotSupportedException("Dynamic assemblies are not supported on iOS.");')
    s=method(s,'OnApplicationQuit','foreach (var mod in mods) BundledModCatalog.Stop(mod);')
    p.write_text(s,encoding='utf-8',newline='\n')
    p=SRC/'LoadedMod.cs';s=p.read_text(encoding='utf-8-sig').replace('using HarmonyLib;','#if !UNITY_IOS\nusing HarmonyLib;\n#endif')
    s=s.replace('\tpublic Harmony HarmonyInstance;','#if !UNITY_IOS\n\tpublic Harmony HarmonyInstance;\n#endif');p.write_text(s,encoding='utf-8')
    p=SRC/'ModScanner.cs';s=p.read_text(encoding='utf-8-sig').replace('using HarmonyLib;','#if !UNITY_IOS\nusing HarmonyLib;\n#endif')
    s=s.replace('\t\tAdd(typeof(Harmony).Assembly.Location);','#if !UNITY_IOS\n\t\tAdd(typeof(Harmony).Assembly.Location);\n#endif');p.write_text(s,encoding='utf-8')
    p=SRC/'ModSteamGuard.cs';s=p.read_text(encoding='utf-8-sig')
    # Explicit unavailable desktop guard; never claim it installed on iOS.
    p.write_text('''#if UNITY_IOS
using System;
public static class ModSteamGuard
{
    public static int GuardedCount => 0;
    public static int BlockedCount => 0;
    public static void Install() => throw new PlatformNotSupportedException("Desktop runtime guards require the desktop mod loader.");
    public static void Verify() => throw new PlatformNotSupportedException("No desktop guards are installed on iOS.");
    public static void Drain() => throw new PlatformNotSupportedException("No desktop mod guard queue exists on iOS.");
}
#else
'''+s+'\n#endif\n',encoding='utf-8')
    p=SRC/'ModSource.cs';s=p.read_text(encoding='utf-8-sig').replace('Workshop','Workshop,\n\tBundled');p.write_text(s,encoding='utf-8')
    p=SRC/'HusbandryHelper.cs';s=p.read_text(encoding='utf-8-sig')
    s,n=re.subn(r'if \(species != null\)(\s*\{\s*AddStatLine\("husbandry_stat_growth_rate")',
                r'if (ItemDetails.AnimalGenes.ShowVanillaStats(species, builder, item))\1',s)
    if n!=1:raise ValueError('Animal gene source edit count: '+str(n))
    p.write_text(s,encoding='utf-8')
    p=SRC/'GameItemElement.cs';s=p.read_text(encoding='utf-8-sig')
    # Only the three exact vanilla tooltip estimates used by upstream's transpiler.
    s,n=re.subn(r'GetCurrentValue\(useRetailMarkup: false, withChild: true, includeEvents: true, forceMarkup: false, 0L\)',
                'ItemDetails.TooltipPipeline.ReadNativeSell(this, false, true, true, false, 0L)',s)
    if n!=3:raise ValueError('Tooltip sell source edit count: '+str(n))
    s,n=re.subn(r'GetBaseValue\(\)', 'ItemDetails.TooltipPipeline.ReadNativeList(this)',s)
    if n!=1:raise ValueError('Tooltip list source edit count: '+str(n))
    p.write_text(s,encoding='utf-8')
    p=PROJECT/'Assets/Plugins/0Harmony.dll.meta';s=p.read_text(encoding='utf-8-sig')
    s=s.replace('enabled: 1\n      settings: {}','enabled: 1\n      settings:\n        Exclude iOS: 1',1)
    s=s.replace('  output:', '  - first:\n      iPhone: iOS\n    second:\n      enabled: 0\n      settings: {}\n  output:')
    p.write_text(s,encoding='utf-8')
    print('Prepared iOS bundled loader and two explicit transpiler-to-source edits.')

if __name__=='__main__':main()
