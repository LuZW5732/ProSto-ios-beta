"""Prepare pinned source-available mods for explicit build-time callback integration."""
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT/'local/cloud-repo/UnityProject'
DEST = PROJECT/'Assets/Scripts/Assembly-CSharp/PortMods'
SOURCES = ROOT/'local/mod-sources'
PINNED = {'item-details':'dcd63fc3463b8483a643e912c2cbd5c0e7335dd2',
          'smart-inventory-arrange':'35b69fde4670feb6c9c04de1de2dd3a9e37fc34f'}

def mask(text):
    pattern = r'//[^\n]*|/\*.*?\*/|@"(?:[^"]|"")*"|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\''
    return re.sub(pattern, lambda m: ''.join('\n' if c=='\n' else ' ' for c in m[0]), text, flags=re.S)

def replace_method(text, name, replacement):
    masked = mask(text)
    match = re.search(r'^\s*(?:public|private|internal|protected)\s+[^\n=;]+\b'+re.escape(name)+r'\([^;]*?\)\s*\{',masked,re.M)
    if not match: raise ValueError('Missing method: '+name)
    start=masked.index('{',match.start());depth=1;end=start+1
    while depth:
        if masked[end]=='{':depth+=1
        elif masked[end]=='}':depth-=1
        end+=1
    return text[:match.start()]+'\n'+replacement+'\n'+text[end:]

def translate(text, smart):
    text=text.replace('using HarmonyLib;', 'using ProbablyStolen.Port.Mods;')
    text=text.replace('HarmonyLib.', 'ProbablyStolen.Port.Mods.')
    for a,b in [('HarmonyMethod','HookMethod'),('Harmony','StaticHookOwner'),('AccessTools','PortReflection'),('Priority','HookPriority')]:
        text=re.sub(r'\b'+a+r'\b',b,text)
    text=text.replace('PortReflection.FieldRef<','Func<').replace('PortReflection.FieldRefAccess<','PortReflection.FieldReader<')
    text=text.replace('ProbablyStolen.Port.Mods.Func<','System.Func<')
    for alias in list(re.finditer(r'^using (\w+) = (\([^;]+\));\s*$',text,re.M)):
        text=text.replace(alias[0],'')
        text=re.sub(r'\b'+alias[1]+r'\b',lambda m:alias[2],text)
    def record(match):
        name,params,bases,op=match.groups()
        fields=[x.strip().rsplit(' ',1) for x in params.split(',')]
        members='\n'.join(f'public {t} {n} {{ get; }}' for t,n in fields)
        members+=f'\npublic {name}({params}) {{ '+''.join(f'this.{n} = {n};' for t,n in fields)+' }'
        members+=f'\npublic bool Equals({name} other) => '+' && '.join(f'EqualityComparer<{t}>.Default.Equals({n}, other.{n})' for t,n in fields)+';'
        members+=f'\npublic override bool Equals(object other) => other is {name} value && Equals(value);'
        members+='\npublic override int GetHashCode() { var h = new System.HashCode();'+''.join(f'h.Add({n});' for t,n in fields)+'return h.ToHashCode(); }'
        members+=f'\npublic static bool operator ==({name} a, {name} b) => a.Equals(b);'
        members+=f'\npublic static bool operator !=({name} a, {name} b) => !a.Equals(b);'
        members+='\npublic void Deconstruct('+', '.join(f'out {t} {n}' for t,n in fields)+') {'+''.join(f'{n} = this.{n};' for t,n in fields)+'}'
        inheritance=(bases.strip()[1:].strip()+', ') if bases else ''
        return f'readonly struct {name} : {inheritance}IEquatable<{name}> {{\n'+members+('\n}' if op==';' else '\n')
    text=re.sub(r'readonly record struct (\w+)\((.*?)\)\s*(:[^\{;]+)?([\{;])',record,text,flags=re.S)
    match=re.search(r'^namespace ([\w.]+);',text,re.M)
    if match:
        stack=[]
        for directive in re.finditer(r'^\s*#(if|endif)\b([^\n]*)',text[:match.start()],re.M):
            if directive[1]=='if':stack.append(directive[2].strip())
            else:stack.pop()
        close='\n}\n'
        if stack:close='\n#if '+ ' && '.join('('+s+')' for s in stack)+close+'#endif\n'
        text=text[:match.start()]+'namespace '+match[1]+'\n{'+text[match.end():]+close
    if smart:
        imports=['System','System.Collections.Generic','System.IO','System.Linq','System.Threading','System.Threading.Tasks']
        text=''.join('using '+name+';\n' for name in imports if 'using '+name+';' not in text)+text
    return '#nullable enable\n'+text

def main():
    DEST.mkdir(parents=True,exist_ok=True)
    for repo,commit in PINNED.items():
        src=SOURCES/(repo+'-'+commit)
        target=DEST/('ItemDetails' if repo=='item-details' else 'SmartInventoryArrange')
        smart=repo!='item-details'
        paths=list((src/'src').rglob('*.cs')) if not smart else list(src.glob('*.cs'))+list((src/'Core').rglob('*.cs'))
        if not smart:
            paths += [p for p in (src/'sdk').rglob('*.cs') if 'csharp5' not in str(p)]
        for path in paths:
            out=target/path.relative_to(src);out.parent.mkdir(parents=True,exist_ok=True)
            text=translate(path.read_text(encoding='utf-8-sig'),smart)
            if path.name=='AnimalGenes.cs':
                text=text.replace('using System.Reflection.Emit;','')
                text=re.sub(r'^.*EqualityComparer<OpCode>.*\n','',text,flags=re.M)
                text=replace_method(text,'ReplaceStatBlock','')
                text=replace_method(text,'MatchesStats','')
                text=replace_method(text,'Install','''    internal static bool PortEnabled;
    internal static void Install(PatchScope scope)
    {
        PortEnabled = true;
        scope.OnDispose(() => PortEnabled = false);
    }''')
                text=text.replace('private static bool ShowVanillaStats','internal static bool ShowVanillaStats')
                text=text.replace('=> species != null && !TryWrite(builder, item, species);',
                                  '=> species != null && (!PortEnabled || !TryWrite(builder, item, species));')
            if path.name=='TooltipPipeline.cs':
                text=text.replace('using System.Reflection.Emit;','')
                text=replace_method(text,'MemoizeNativeValues','')
                text=re.sub(r',\s*transpiler:\s*new HookMethod\(typeof\(TooltipPipeline\), nameof\(MemoizeNativeValues\)\)', '',text)
                text=text.replace('private static long ReadNative','internal static long ReadNative')
            if path.name=='ValueBreakdown.cs':
                text=replace_method(text,'ForeignPatches','''    private static bool ForeignPatches(System.Reflection.MethodBase method)
        => ProbablyStolen.Port.Mods.StaticModHooks.HasForeignHooks(method, "item_details");''')
                text=re.sub(r'private static bool Mine\(ProbablyStolen.Port.Mods.Patch patch\)\s*=>.*?;', '',text,flags=re.S)
            if path.name=='CallbackEvidence.cs':
                text=replace_method(text,'Scan','''    private static bool Scan(MethodBase method, MethodInfo target, int depth, HashSet<MethodBase> visited)
    {
        // IL2CPP has no readable managed method body. Do not fabricate evidence
        // for third-party callbacks; keep upstream's conservative fallback.
        return false;
    }''')
            if path.name=='TooltipLine.cs':
                text=text.replace('        Text = text;', '        this = default;\n        Text = text;')
            if path.name=='ModEntry.cs' and not smart:
                text=text.replace('var cb = OnTooltipLate;', 'Action<RichTextBuilder, GameItem> cb = OnTooltipLate;')
            if path.name=='ModEntry.cs' and smart:
                marker='Patch("OnEventInit", typeof(ContextInitPatch), nameof(ContextInitPatch.Postfix), false);'
                assert marker in text
                text=text.replace(marker, marker+'\n            Patch("TryOpenSortMenu", typeof(ContextInitPatch), nameof(ContextInitPatch.Postfix), false);')
                marker='            _harmony = null;\n        }\n    }'
                assert marker in text
                text=text.replace(marker, '            _harmony = null;\n            ModRuntime.Stop();\n            throw;\n        }\n    }', 1)
            if path.name=='LiquidQueries.cs':
                client=(src/'sdk/ItemDetailsClient.cs').read_text(encoding='utf-8-sig')
                payload=re.search(r'^using LiquidPayload = ([^;]+);',client,re.M)[1]
                text=text.replace('Delegate AnalysisQuery =', 'Func<GameItem, '+payload+'?> AnalysisQuery =')
            if path.name=='FrozenPreferenceModel.cs':
                old='typeof(FrozenPreferenceModel).Assembly.GetManifestResourceStream("SmartInventoryArrange.directional21.json")'
                text=text.replace(old,'ProbablyStolen.Port.Mods.BundledModResources.Open("SmartInventoryArrange/directional21")')
            out.write_text(text,encoding='utf-8',newline='\n')
        notices=PROJECT/'ThirdPartyNotices'/repo;notices.mkdir(parents=True,exist_ok=True)
        for name in ['LICENSE','UPSTREAM-LICENSE.txt','README.md','manifest.xml']:
            if (src/name).exists():shutil.copy2(src/name,notices/name)
        resource=PROJECT/'Assets/StreamingAssets/PortMods'/('SmartInventoryArrange' if smart else 'ItemDetails')
        resource.mkdir(parents=True,exist_ok=True)
        shutil.copy2(src/'manifest.xml',resource/'manifest.xml')
        for path in (src/'Localization').rglob('*'):
            if path.is_file():
                out=resource/'Localization'/path.relative_to(src/'Localization');out.parent.mkdir(parents=True,exist_ok=True)
                shutil.copy2(path,out)
        if smart:shutil.copy2(src/'Models/directional21.json',resource/'directional21.json')
    runtime=DEST/'Runtime';runtime.mkdir(exist_ok=True)
    for path in (ROOT/'PortModRuntime').glob('*.cs'):shutil.copy2(path,runtime/path.name)
    (PROJECT.parent/'BUNDLED-MOD-SOURCES.json').write_text(json.dumps(PINNED,indent=2),encoding='utf-8')
    print('Prepared pinned sources and callback runtime. Build-time entry generation is still required.')

if __name__=='__main__':main()
