@echo off
setlocal

cd /d "%~dp0"
set "SCRIPT=%~dp0desktop_auto_organizer.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] Could not find:
    echo %SCRIPT%
    pause
    exit /b 1
)

echo Running organizer...
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "ERR=%ERRORLEVEL%"

echo.
if not "%ERR%"=="0" (
    echo [ERROR] PowerShell exited with code %ERR%
    echo.
    echo Try this manually in PowerShell:
    echo powershell -ExecutionPolicy Bypass -File "%SCRIPT%"
) else (
    echo Done.
)

pause
endlocal
