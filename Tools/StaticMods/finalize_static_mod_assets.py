"""Add stable Unity metadata and mirror reviewed port assets without deleting user files."""
from pathlib import Path
import shutil
import uuid

ROOT = Path(__file__).resolve().parent
repo = ROOT/'local/cloud-repo'
assets = repo/'UnityProject/Assets'
generated = ['Scripts/Assembly-CSharp/PortMods', 'StreamingAssets/PortMods', 'PortModPreservation']
for relative in generated:
    folder = assets/relative
    for path in [folder, *sorted(folder.rglob('*'))]:
        if path.suffix == '.meta' or path.name.startswith('.'):
            continue
        meta = Path(str(path)+'.meta')
        if meta.exists():
            continue
        guid = uuid.uuid5(uuid.NAMESPACE_URL, 'probably-stolen-ios/'+path.relative_to(assets).as_posix()).hex
        body = 'fileFormatVersion: 2\nguid: '+guid+'\n'
        if path.is_dir():
            body += 'folderAsset: yes\nDefaultImporter:\n  externalObjects: {}\n'
        elif path.suffix == '.cs':
            body += 'MonoImporter:\n  externalObjects: {}\n  serializedVersion: 2\n  defaultReferences: []\n  executionOrder: 0\n  icon: {instanceID: 0}\n'
        else:
            body += 'DefaultImporter:\n  externalObjects: {}\n'
        body += '  userData: \n  assetBundleName: \n  assetBundleVariant: \n'
        meta.write_text(body, encoding='utf-8')

mirror = ROOT/'local/recovered-project/ExportedProject/Assets'
for relative in generated:
    shutil.copytree(assets/relative, mirror/relative, dirs_exist_ok=True)
    shutil.copy2(Path(str(assets/relative)+'.meta'), Path(str(mirror/relative)+'.meta'))
backup = ROOT/'local/static-mod-backup'
count = 0
for source in (assets/'Scripts/Assembly-CSharp').glob('*.cs'):
    original = backup/source.name
    if original.exists() and source.read_bytes() != original.read_bytes():
        shutil.copy2(source, mirror/'Scripts/Assembly-CSharp'/source.name)
        count += 1
shutil.copy2(assets/'Plugins/0Harmony.dll.meta', mirror/'Plugins/0Harmony.dll.meta')
print(f'Generated stable metadata; mirrored {count} changed game sources and bundled assets.')
