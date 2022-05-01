@echo off

setlocal

SET SDIR=%1
SET DDIR=%2

IF EXIST "%SDIR%" GOTO CONFIRM1

echo.
echo Source Directory does not exist.
echo.

goto EOF

:CONFIRM1

IF EXIST "%DDIR%" GOTO CONFIRM2

echo.
echo Destination Directory does not exist.
echo.

goto EOF

:CONFIRM2

echo.
echo Synchronizing %SDIR% to %DDIR%...
echo.

robocopy "%SDIR%" "%DDIR%" /MIR /Z /MT /COPY:DAT /DCOPY:T /V /TIMFIX /R:1 /W:5

:EOF
