@echo off

setlocal

set TFILE=%TEMP%\%RANDOM%.dat

net user %USERNAME% /domain | findstr "Full Name" > %TFILE%

for /F "usebackq tokens=* delims=" %%A in (%TFILE%) do set the_line=%%A

for /F "usebackq tokens=1,2,3,4 delims=~" %%1 in ('%the_line: =~%') do set FULLNAME=%%3 %%4

echo %FULLNAME%

del %TFILE% 2>nul 1>nul

endlocal
