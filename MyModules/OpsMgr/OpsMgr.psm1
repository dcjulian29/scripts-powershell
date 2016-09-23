Function Load-OpsMgrShell {
    Import-Module OperationsManager
    & "C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Powershell\OperationsManager\Functions.ps1"
    & "C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Powershell\OperationsManager\Startup.ps1"
}

Export-ModuleMember Load-OpsMgrShell
