setlocal

WhoAmI /Groups | %WINDIR%\System32\find.exe "S-1-16-12288" >nul 2>nul

if %ERRORLEVEL% EQU 0 exit /b 99

if [%1] EQU [YES] goto PROMPTTOELEVATE

echo.
echo This command requires elevation and you are not running with elevated privileges.
echo.

goto EOF

:PROMPTTOELEVATE

choice /m "Should I elevate for this command?"

if %ERRORLEVEL% EQU 1 goto ELEVATE

exit /b 2

:ELEVATE

shift
set PARAM=%1

:LOOP

shift
if [%1] EQU [] goto AFTERLOOP
set PARAM=%PARAM% %1
goto LOOP

:AFTERLOOP

call %SYSTEMDRIVE%\Tools\binaries\elevate.bat %PARAM%

:EOF

endlocal
