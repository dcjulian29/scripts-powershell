@echo off

setlocal

set PATH=%SYSTEMDRIVE%\Tools\apps\bind-tools;%PATH%

dig.exe %*

endlocal
