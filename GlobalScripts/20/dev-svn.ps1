$env:Path = "$env:Path;c:\bin\development-tools\svn\bin"

Import-Module Posh-SVN

$SvnPromptSettings.BeforeText = "["
