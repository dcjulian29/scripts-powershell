@echo off

if not "%1" == "" goto C1

echo.
echo Please provide a brightness percentage...
echo.

goto EOF

:C1

call %SYSTEMDRIVE%\Tools\binaries\_isElevated.cmd YES "%0" %*
if %ERRORLEVEL% NEQ 99 goto EOF

setlocal

echo.
echo Setting monitor brightness to %1%%...

set PCMD=Set-MonitorBrightness %1

call %~dp0pshell.cmd "%PCMD%"

echo.

endlocal

:EOF
