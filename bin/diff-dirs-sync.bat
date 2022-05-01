@echo off

:: %1 -- Hostname to run on
:: %2 -- Source Directory
:: %3 -- Destination Directory
:: %4 -- Filter to use

if [%1] == [*] goto CORRECTHOST
if [%COMPUTERNAME%] == [%1] goto CORRECTHOST

echo.
echo Run this script only on %1
echo.

pause

goto EOF

:CORRECTHOST

IF [%4] NEQ [] set FILTER=/f %4

if exist "%2" goto SRCEXIST

echo.
echo Source Directory does not exist...
echo.

pause

goto EOF

:SRCEXIST

if exist %3 goto DSTEXIST

echo.
echo Destination Directory does not exist...
echo.

pause

goto EOF

:DSTEXIST

%~dp0diff-dirs.bat %FILTER% %2 %3

:EOF
