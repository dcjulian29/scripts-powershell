@echo off

setlocal

set FVER=%date:~-4,4%%date:~-10,2%%date:~-7,2%
set SDIR=%1
set ODIR=%CD%

if [%1] == [] set SDIR=%CD%

if [%SDIR%] NEQ [%ODIR%] pushd %SDIR%

SET FNAME=
FOR %%A in (%CD:\= %) DO SET FNAME=%%A

SET DDIR=%FNAME%.%FVER%.7z

if [%SDIR%] NEQ [%ODIR%] popd
if [%SDIR%] EQU [%CD%] pushd ..

call %SYSTEMDRIVE%\Tools\binaries\7zip.cmd a -t7z -mx9 -y -r  %DDIR% %SDIR%
