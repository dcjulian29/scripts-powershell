@echo off
taskkill /IM explorer.exe /F
cd /d %USERPROFILE%\Local Settings\Application Data
del /A:H IconCache.db
explorer.exe