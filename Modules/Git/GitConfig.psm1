function Get-GitConfigValue {
    [CmdletBinding()]
    param (
        [string] $Key
    )

    $parameters = "config --get $Key"

    cmd /c """$(Find-Git)"" $parameters"
}

function Set-GitConfigValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $key,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $value,
        [ValidateSet("global", "local", "system")]
        [string] $Scope = "local"
    )

    $parameters = "config"

    if ([System.String]::IsNullOrEmpty($Value)) {
        $parameters += " --unset $Key"
    } else {
        $parameters += " --$Scope $Key '$Value'"
    }
}
