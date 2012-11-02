$env:Path = "$env:Path;c:\bin\development-tools\mercurial"

Import-Module Posh-HG

$PoshHgSettings.BeforeText = "["
