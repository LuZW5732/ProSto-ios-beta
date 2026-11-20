param(
    [string]$GameDir = 'E:/SteamLibrary/steamapps/common/Probably Stolen',
    [string]$SourceDir = "$PSScriptRoot/local/recovered-project/ExportedProject/Assets/Scripts/Assembly-CSharp",
    [switch]$IOS,
    [switch]$PrepareOnly
)
$ErrorActionPreference = 'Stop'
$managed = Join-Path $GameDir 'Probably Stolen_Data/Managed'
$source = (Resolve-Path -LiteralPath $SourceDir).Path
$output = Join-Path $PSScriptRoot 'local/code-validation'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$xml = [System.Xml.XmlWriter]::Create((Join-Path $output 'CodeValidation.csproj'), [System.Xml.XmlWriterSettings]@{Indent=$true})
try {
    $xml.WriteStartElement('Project'); $xml.WriteAttributeString('Sdk','Microsoft.NET.Sdk')
    $xml.WriteStartElement('PropertyGroup')
    $properties = @{TargetFramework='netstandard2.1'; AssemblyName='Assembly-CSharp'; GenerateAssemblyInfo='false'; EnableDefaultCompileItems='false'; AllowUnsafeBlocks='true'; LangVersion='9.0'}
    if ($IOS) { $properties.DefineConstants = 'UNITY_IOS' }
    foreach ($entry in $properties.GetEnumerator()) { $xml.WriteElementString($entry.Key,$entry.Value) }
    $xml.WriteEndElement()
    $xml.WriteStartElement('ItemGroup')
    $xml.WriteStartElement('Compile'); $xml.WriteAttributeString('Include',"$source/**/*.cs"); $xml.WriteAttributeString('Exclude',"$source/**/obj/**;$source/**/bin/**"); $xml.WriteEndElement()
    foreach ($file in Get-ChildItem -LiteralPath $managed -Filter '*.dll') {
        if ($file.BaseName -eq 'Assembly-CSharp' -or $file.BaseName -match '^(mscorlib|netstandard|System($|\.)|Microsoft\.)') { continue }
        if ($IOS -and $file.BaseName -eq '0Harmony') { continue }
        $xml.WriteStartElement('Reference'); $xml.WriteAttributeString('Include',$file.BaseName)
        $xml.WriteElementString('HintPath',$file.FullName); $xml.WriteElementString('Private','false'); $xml.WriteEndElement()
    }
    $xml.WriteEndElement(); $xml.WriteEndElement()
} finally { $xml.Dispose() }
if ($PrepareOnly) { return }
& dotnet build (Join-Path $output 'CodeValidation.csproj') --nologo -v quiet *> (Join-Path $output 'build.log')
$buildExit = $LASTEXITCODE
Get-Content (Join-Path $output 'build.log') -Tail 8
exit $buildExit
