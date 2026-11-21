param(
    [Parameter(Mandatory)][string]$GameManagedDir,
    [Parameter(Mandatory)][string]$OutputDir
)
$ErrorActionPreference = 'Stop'
$managed = (Resolve-Path $GameManagedDir).Path
$out = (New-Item -Force -ItemType Directory $OutputDir).FullName
$sdk = dotnet --version
$spec = dotnet --list-sdks | Where-Object { $_.StartsWith("$sdk [") } | Select-Object -First 1
if (!$spec) { throw 'Selected .NET SDK not found' }
$csc = Join-Path ($spec.Substring($sdk.Length + 2).TrimEnd(']')) "$sdk/Roslyn/bincore/csc.dll"
$refs = @("/r:$managed/mscorlib.dll", "/r:$managed/System.dll", "/r:$managed/netstandard.dll")
dotnet $csc /nologo /nostdlib /target:library @refs "/r:$managed/Assembly-CSharp.dll" "/out:$out/ProStoModProbe.dll" "$PSScriptRoot/Probe.cs"
if ($LASTEXITCODE) { throw 'Probe DLL compilation failed' }
$hostSource = "$PSScriptRoot/../../UnityProject/Assets/Scripts/Assembly-CSharp/ProStoProbeHost.cs"
dotnet $csc /nologo /nostdlib /define:PROSTO_DYNAMIC_MOD_PROBE /target:exe @refs "/out:$out/ProbeHost.exe" $hostSource "$PSScriptRoot/Program.cs"
if ($LASTEXITCODE) { throw 'Probe host compilation failed' }
