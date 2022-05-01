@echo off
setlocal

set W=%1
set H=%2

if [%W%] NEQ [] goto CHECKH

echo.
echo Please provide Weight in pounds.
echo.

goto EOF

:CHECKH

if [%H%] NEQ [] goto CALC

echo.
echo Please provide Height in inches.
echo.


goto EOF

:CALC

set CALC="BMI is $([decimal]::round(((%W%/2.2)/(((%H%*2.54)/100)*((%H%*2.54)/100))*100)/100,2))"


call %~dp0pshell.cmd "%CALC%"

:EOF

endlocal


