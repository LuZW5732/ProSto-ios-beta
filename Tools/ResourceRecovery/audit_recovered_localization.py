"""Check recovered tables against the exact missing keys reported on the device."""
from pathlib import Path
import re, sys, collections
ROOT = Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'tooling/python'))
import yaml

def read(path):
    text = path.read_text(encoding='utf-8-sig')
    text = re.sub(r'^%.*\n|^--- !u!\d+ &\d+\n','',text,flags=re.M)
    return yaml.load(text, Loader=getattr(yaml, 'CSafeLoader', yaml.SafeLoader))['MonoBehaviour']

assets = ROOT/'local/cloud-repo/UnityProject/Assets/Resources/emporium/localization'
shared = {}
tables = {}
for p in assets.rglob('*.asset'):
    data = read(p)
    if 'm_TableCollectionName' not in data: continue
    guid = re.search(r'^guid: (\w+)', Path(str(p)+'.meta').read_text(), re.M)[1]
    shared[guid] = (data['m_TableCollectionName'], {e['m_Id']: e['m_Key'] for e in data['m_Entries']})
for p in assets.rglob('*.asset'):
    data = read(p)
    if 'm_TableData' not in data: continue
    name, keys = shared[data['m_SharedData']['guid']]
    key = (data['m_LocaleId']['m_Code'], name)
    entries = {keys[e['m_Id']]:e['m_Localized'] for e in data['m_TableData']}
    if key in tables: assert tables[key] == entries, f'Conflicting table: {key}'
    tables[key] = entries
locales = ['en','ja','de','ru','zh','fr','es','pl']
required = [('UI','ui_endofday_info'),('Mechanic','mech_day_label'),('NewGame','generalist_body')]
for locale in locales:
    for collection,key in required:
        value = tables[(locale,collection)][key]
        assert value and value != key, (locale,collection,key)
        if locale == 'zh': print(collection+'/'+key+': '+str(value)[:120])
assert len(locales) >= 8
print(f'PASS: {len(tables)} unique locale/table pairs, languages={locales}; duplicate exports agree; required keys exist in every locale.')
