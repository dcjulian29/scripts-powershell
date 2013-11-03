if (Test-Path "$env:SYSTEMDRIVE\Program Files (x86)\")
{
  $GIT_INSTALL_ROOT = "$env:SYSTEMDRIVE\Program Files (x86)\Git\bin"
}
else
{
  $GIT_INSTALL_ROOT = "$env:SYSTEMDRIVE\Program Files\Git\bin"
}

if (Test-Path "$GIT_INSTALL_ROOT")
{
  $env:Path = "$env:Path;$GIT_INSTALL_ROOT"

  Import-Module Posh-Git

  Enable-GitColors

  $GitPromptSettings.BeforeText = "["

  $GIT = "$GIT_INSTALL_ROOT\git.exe"

  function gb { ."C:\bin\development-tools\git-backup.bat" }
  function gbr { ."C:\bin\development-tools\git-backup-remove.bat" }

  function gpull { cmd.exe /c "$GIT" pull }
  function gpush { cmd.exe /c "$GIT" push }
  function gs { cmd.exe /c "$GIT" status }
}