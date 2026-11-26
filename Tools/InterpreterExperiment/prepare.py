from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import tempfile
import zipfile

SDK = "https://github.com/focus-creative-games/hybridclr_unity.git#0642726469f34319f27131237784dd37e1784fc5"
SAMPLE = "22c21e0671dd7ee531ca17d93060cda1bf53d8bc00ba62e15620a56fb5355501"
REPUTATION_SAMPLE = "5b748ee68f0184fe26950db4b4d0e1fc1668bf1cc2d5e0221cf9583e10f5a979"


def prepare(destination, dll, sdk_checkout=None, reputation_dll=None):
    tools = Path(__file__).resolve().parent.parent
    project = tools.parent / "UnityProject"
    destination = destination.resolve()
    if project == destination or project in destination.parents:
        raise ValueError("Choose a new directory outside UnityProject")
    if hashlib.sha256(dll.read_bytes()).hexdigest() != SAMPLE:
        raise ValueError("Expected original Workshop ShutterEvents 1.3.4")
    if reputation_dll is not None and hashlib.sha256(reputation_dll.read_bytes()).hexdigest() != REPUTATION_SAMPLE:
        raise ValueError("Expected original Workshop ReputationPop 1.1.0")
    destination.mkdir(parents=True, exist_ok=False)
    copy = destination / "UnityProject"
    for folder in ("Assets", "Packages", "ProjectSettings"):
        shutil.copytree(project / folder, copy / folder)
    # The isolated iOS experiment uses an attribute-only ABI with the same
    # assembly identity. Do not import the desktop Harmony plug-in alongside it.
    for name in ("0Harmony.dll", "0Harmony.dll.meta"):
        (copy / "Assets/Plugins" / name).unlink(missing_ok=True)
    shutil.copytree(tools / "InterpreterExperiment/HarmonyAbi", copy / "Assets/PortHarmonyAbi")
    # Use the same on-disk package layout as the Mac experiment. The installer's
    # build tools read files beneath Packages/com.code-philosophy.hybridclr.
    url, revision = SDK.split("#")
    with tempfile.TemporaryDirectory() as temp:
        if sdk_checkout is None:
            sdk_checkout = Path(temp) / "sdk"
            subprocess.run(["git", "clone", "--quiet", "--depth", "1", "--branch", "v8.5.0",
                            url, str(sdk_checkout)], check=True)
        archive = Path(temp) / "sdk.zip"
        subprocess.run(["git", "-C", str(sdk_checkout), "archive", "--format=zip",
                        "-o", str(archive), revision], check=True)
        with zipfile.ZipFile(archive) as package:
            package.extractall(copy / "Packages/com.code-philosophy.hybridclr")
    manifest = copy / "Packages/manifest.json"
    settings = json.loads(manifest.read_text(encoding="utf-8-sig"))
    settings["dependencies"]["com.code-philosophy.hybridclr"] = "8.5.0"
    manifest.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf-8")
    with (copy / "Assets/csc.rsp").open("a", encoding="utf-8") as rsp:
        rsp.write("\n-define:PROSTO_INTERP\n")
    # Input for bridge generation only. This directory is outside player assets.
    refs = copy / "WorkshopReference"
    refs.mkdir()
    shutter = refs / "ShutterEvents"
    shutter.mkdir()
    shutil.copyfile(dll, shutter / "ShutterEvents.dll")
    shutil.copyfile(dll.parent / "manifest.xml", shutter / "manifest.xml")
    shutil.copytree(dll.parent / "Localization", shutter / "Localization")
    if reputation_dll is not None:
        reputation = refs / "ReputationPop"
        reputation.mkdir()
        shutil.copyfile(reputation_dll, reputation / "ReputationPop.dll")
        shutil.copyfile(reputation_dll.parent / "manifest.xml", reputation / "manifest.xml")
        localization = reputation_dll.parent / "Localization"
        if localization.is_dir():
            shutil.copytree(localization, reputation / "Localization")
    for name in ("PortInterpreterBuild.cs", "WorkshopBindingCheck.cs"):
        shutil.copyfile(tools / "InterpreterExperiment" / name, copy / "Assets/Editor" / name)
    scripts = destination / "Tools"
    scripts.mkdir()
    shutil.copy2(tools / "build-ios-local.sh", scripts)
    shutil.copy2(tools / "InterpreterExperiment/build.sh", scripts)
    print(destination)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("destination", type=Path)
    parser.add_argument("dll", type=Path)
    parser.add_argument("--sdk-checkout", type=Path, help="Existing clone containing the pinned SDK commit")
    parser.add_argument("--reputation-dll", type=Path, help="Original Workshop ReputationPop 1.1.0 DLL")
    args = parser.parse_args()
    prepare(args.destination, args.dll, args.sdk_checkout, args.reputation_dll)
