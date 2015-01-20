Function Restart-IISAppPool {
<#
.SYNOPSIS
    Restarts an IIS AppPool 

.PARAMETER ComputerName 
    The name of the server hosting the Application Pool.

.PARAMETER AppPool 
    The name of the Application Pool to recycle.

.PARAMETER Credential 
    Credentials to use when connecting to the IIS Server

#Requires -Version 2.0
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory= $true, Position=0)]
        [Alias("Name","Pool")]
        [String[]]$AppPool,

        [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("RemoteHost","Server")]
        [String]$ComputerName,

        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN {
        if ($Credential -and ($Credential -ne [System.Management.Automation.PSCredential]::Empty)) {
            $Credential = $Credential.GetNetworkCredential()
        }

        $skipProcessBlock = $false

        if ($PSBoundParameters.ContainsKey("AppPool") -and $AppPool -match "\*") {
            $null = $PSBoundParameters.Remove("AppPool")
            $null = $PSBoundParameters.Remove("WhatIf")
            $null = $PSBoundParameters.Remove("Confirm")

            Write-Verbose "Searching for AppPools matching: $($AppPool -join ', ')"
 
            Get-WmiObject IISApplicationPool -Namespace root\MicrosoftIISv2 `
                -Authentication PacketPrivacy @PSBoundParameters | 
                Where-Object {
                    @(foreach($pool in $AppPool) {
                        $_.Name -like $Pool -or $_.Name -like "W3SVC/APPPOOLS/$Pool"
                    }) -contains $true } | Restart-IISAppPool

            $skipProcessBlock = $true
        }

        $ProcessNone = $ProcessAll = $false;
    }

    PROCESS {
        if (!$skipProcessBlock) {
            $null = $PSBoundParameters.Remove("AppPool")
            $null = $PSBoundParameters.Remove("WhatIf")
            $null = $PSBoundParameters.Remove("Confirm")

            foreach ($pool in $AppPool) {
                if ($PSCmdlet.ShouldProcess( `
                    "Restart $Pool on $(if ($ComputerName) { $ComputerName } else { 'this server' }).", `
                    "Restart ${Pool}?", `
                    "Restarting IIS App Pools on $ComputerName")) {
                        Write-Verbose "Restarting $Pool on $(if ($ComputerName) { $ComputerName } else { 'this server' })."
                        Invoke-WMIMethod Recycle `
                            -Path "IISApplicationPool.Name='$Pool'" `
                            -Namespace root\MicrosoftIISv2 `
                            -Authentication PacketPrivacy @PSBoundParameters
                }
            }
        }
    }

    END { } 
}

###############################################################################

Export-ModuleMember Restart-IISAppPool
