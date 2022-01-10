function Find-SqlCmd {
    return Find-FirstPath `
        (Find-ProgramFiles 'Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe') `
        (Find-ProgramFiles 'Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe') `
        (Find-ProgramFiles 'Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe') `
        "$pwd\sqlcmd.exe"
}

function Invoke-SqlCmd {
    cmd /c """$(Find-SqlCmd)"" $args"
}

function Invoke-SqlFile {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path,
        [string] $SqlServer
    )

    if ($SqlServer) {
        $env:SQLCMDSERVER = $SqlServer
    }

    $sqlFile = "${env:TEMP}\$((New-Guid).Guid).sql"

        Set-Content -Path $sqlFile -Value @"
BEGIN TRANSACTION SQLCMDT1

PRINT '--- Execution Starting ---'
PRINT '    $SqlFile'

GO

$(Get-Content -Path $Path -Raw)

GO

PRINT '--- Execution Finished ---'
IF (@@ERROR <> 0)
BEGIN
    PRINT 'Error Occurred, rolling transaction back'
    ROLLBACK TRANSACTION SQLCMDT1
END
ELSE
    COMMIT TRANSACTION SQLCMDT1

GO
"@

    Invoke-SqlCmd -i $sqlFile -r 1 -b
}

function Register-SqlCmdSqlCredentials {
    param (
        [pscredential] $Credentials = $(Get-Credential -Message "Enter SQL Credentials...")
    )

    $env:SQLCMDUSER = $Credentials.UserName
    $env:SQLCMDPASSWORD = $Credentials.GetNetworkCredential().password
}

function Start-MSSqlServer {
    & sc.exe start MSSQLSERVER
}

Set-Alias -Name mssql-start -Value Start-MSSqlServer

function Stop-MSSqlServer {
    & sc.exe stop MSSQLSERVER
}

Set-Alias -Name mssql-stop -Value Stop-MSSqlServer
