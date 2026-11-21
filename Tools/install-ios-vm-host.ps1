param(
    [Parameter(Mandatory)]
    [string]$MacDestination,
    [string]$BootstrapDirectory
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$gitRoot = Split-Path -Parent (Split-Path -Parent (Get-Command git.exe).Source)
$bash = Join-Path $gitRoot 'bin\bash.exe'

if ($BootstrapDirectory) {
    $key = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.ssh\probablystolen_vm_ed25519'
    if (!(Test-Path -LiteralPath $key)) {
        & $bash -c 'umask 077; mkdir -p "$HOME/.ssh" && ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/probablystolen_vm_ed25519"'
        if ($LASTEXITCODE -ne 0) { throw 'Could not generate the SSH key.' }
    }
    Copy-Item -LiteralPath "$key.pub" -Destination (Join-Path $BootstrapDirectory 'windows-build.pub')
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'ios-vm-worker.sh') `
        -Destination (Join-Path $BootstrapDirectory 'worker.sh')
}

& $bash (Join-Path $PSScriptRoot 'ios-vm-host.sh') install $MacDestination
if ($LASTEXITCODE -ne 0) { throw 'Could not install the Git commit hook.' }

$build = Join-Path $repo 'build'
New-Item -ItemType Directory -Force -Path $build | Out-Null
$taskName = 'ProbablyStolen iOS VM Sync'
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing -and $existing.Actions.WorkingDirectory -ne $repo) {
    throw 'A scheduled task already exists for another checkout.'
}

$shellPath = $bash.Replace("'", "''")
$command = "& '$shellPath' -c 'bash Tools/ios-vm-host.sh sync > build/vm-sync.log 2>&1'"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -WorkingDirectory $repo `
    -Argument ('-NoProfile -NonInteractive -WindowStyle Hidden -Command "' + $command + '"')
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
    -RepetitionInterval (New-TimeSpan -Minutes 1)
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal `
    -Settings $settings -Force | Out-Null
Write-Output "Installed $taskName. Windows will sync queued commits and completed builds once a minute."
