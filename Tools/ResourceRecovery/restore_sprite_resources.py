"""Recover Resources sprite subasset paths from the PC ResourceManager index."""
from pathlib import Path
import json, re, sys, uuid
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'tooling/unitypy'))
import UnityPy
PROJECT = ROOT/'local/cloud-repo/UnityProject'
ASSETS = PROJECT/'Assets'
GAME = Path('E:/SteamLibrary/steamapps/common/Probably Stolen/Probably Stolen_Data')

def guid_for(path):
    return uuid.uuid5(uuid.NAMESPACE_URL, 'probably-stolen-ios/'+path).hex

def main():
    candidates = {}
    for path in sorted(ASSETS.rglob('*.asset')):
        source = path.read_text(encoding='utf-8-sig')
        if '\nSprite:\n' not in source: continue
        match = re.search(r'm_RenderDataKey:\s*\n\s*([0-9a-f]{32}): (-?\d+)', source)
        if not match: continue
        key = (match[1], int(match[2]))
        guid = re.search(r'^guid: (\w+)', Path(str(path)+'.meta').read_text(), re.M)[1]
        name = re.search(r'^  m_Name: (.*)$', source, re.M)[1]
        candidates.setdefault(key, []).append((path, guid, name))
    env = UnityPy.load(str(GAME/'globalgamemanagers'))
    manager = next(o for o in env.objects if o.type.name == 'ResourceManager').read()
    entries, missing = [], []
    for resource, pointer in manager.m_Container:
        if not pointer.m_PathID: continue
        obj = pointer.deref()
        if obj.type.name != 'Sprite': continue
        sprite = obj.read_typetree()
        raw, local = sprite['m_RenderDataKey']
        key = (''.join(f'{raw[f"data[{i}]"]:08x}'[::-1] for i in range(4)), local)
        matches = [c for c in candidates.get(key, []) if c[2] == sprite['m_Name']]
        if not matches:
            missing.append((resource, sprite['m_Name'], key)); continue
        matches.sort(key=lambda c: (not '/Resources/' in c[0].as_posix(), len(c[0].as_posix()), c[0].as_posix()))
        path, guid, name = matches[0]
        entries.append(dict(path=resource, name=name, guid=guid, asset=str(path.relative_to(ASSETS))))
    report = ROOT/'local/sprite-resource-map.json'
    report.write_text(json.dumps(dict(entries=entries, missing=missing),ensure_ascii=False,indent=2),encoding='utf-8')
    if missing: raise RuntimeError(f'{len(missing)} unmapped sprites; see {report}')
    script_guid = guid_for('PortSpriteResources.cs')
    output = ASSETS/'Resources/PortSpriteResources.asset'
    text = '%YAML 1.1\n%TAG !u! tag:unity3d.com,2011:\n--- !u!114 &11400000\nMonoBehaviour:\n  m_ObjectHideFlags: 0\n  m_CorrespondingSourceObject: {fileID: 0}\n  m_PrefabInstance: {fileID: 0}\n  m_PrefabAsset: {fileID: 0}\n  m_GameObject: {fileID: 0}\n  m_Enabled: 1\n  m_EditorHideFlags: 0\n  m_Script: {fileID: 11500000, guid: '+script_guid+', type: 3}\n  m_Name: PortSpriteResources\n  m_EditorClassIdentifier:\n  entries:\n'
    for entry in entries:
        text += '  - path: '+json.dumps(entry['path'])+'\n    sprite: {fileID: 21300000, guid: '+entry['guid']+', type: 2}\n'
    output.write_text(text,encoding='utf-8')
    for relative, guid, importer in [
        ('Scripts/Assembly-CSharp/PortSpriteResources.cs',script_guid,'MonoImporter'),
        ('Resources/PortSpriteResources.asset',guid_for('PortSpriteResources.asset'),'NativeFormatImporter'),
        ('Scripts/Assembly-CSharp/PortLocalizationBootstrap.cs',guid_for('PortLocalizationBootstrap.cs'),'MonoImporter')]:
        meta = ASSETS/(relative+'.meta')
        if not meta.exists():
            meta.write_text('fileFormatVersion: 2\nguid: '+guid+'\n'+importer+':\n  externalObjects: {}\n  userData: \n  assetBundleName: \n  assetBundleVariant: \n',encoding='utf-8')
    print(f'Recovered {len(entries)} sprite resource entries; missing=0')

if __name__ == '__main__': main()
