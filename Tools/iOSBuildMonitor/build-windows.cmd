@echo off
setlocal
set "out=%~dp0..\..\build\vm-monitor"
set "name=iOS Build Monitor"
if "%~1"=="low-bandwidth" set "name=iOS Build Monitor (low bandwidth)"
if not exist "%out%" mkdir "%out%"
"%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /target:winexe /platform:x64 /codepage:65001 /r:System.Windows.Forms.dll /r:System.Drawing.dll /resource:"%~dp0read-vm-logs.sh",read-vm-logs.sh /out:"%out%\%name%.exe" "%~dp0BuildMonitor.cs"
exit /b %ERRORLEVEL%
