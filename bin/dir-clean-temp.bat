@echo off
setlocal

set PCMD=Purge-Files -Folder "%TEMP%" -Filter "*.*" -Age 7
call %~dp0pshell.cmd "%PCMD%"

endlocal
