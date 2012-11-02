$env:Path = "$env:Path;c:\bin\development-tools\msysgit\bin"

Import-Module Posh-Git

Enable-GitColors

$GitPromptSettings.BeforeText = "["

$GIT = "C:\bin\development-tools\msysgit\bin\git.exe"

function gb { ."C:\bin\development-tools\git-backup.bat" }
function gbr { ."C:\bin\development-tools\git-backup-remove.bat" }
function gsc { ."C:\bin\development-tools\git-svn-commit-project.bat" }
function gsu { ."C:\bin\development-tools\git-svn-update-project.bat" }
