@echo off

setlocal

SET SDIR=%1
SET DDIR=%2

IF EXIST %SDIR% GOTO CONFIRM

echo.
echo Source Directory does not exist.
echo.

goto EOF

:CONFIRM

echo.
echo Preparing to copy %SDIR% to %DDIR%...
echo.
echo Press Ctrl-C to cancel or
pause

robocopy %SDIR% %DDIR% /MIR /ZB /SL /MT /XJ /R:5 /W:5

:EOF
