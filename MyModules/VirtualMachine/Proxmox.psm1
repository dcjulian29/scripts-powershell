Function ConvertFrom-UnixTime {
    param (
        [long] $time
    )

    $epoch = (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0).ToLocalTime()

    return $epoch.AddSeconds($time)
}

Function Get-ServerResponse {
    param (
        $pve,
        $action,
        $method = "Get",
        $body = ""
    )

    $url = "https://$($pve.ServerName):8006/api2/json/$action"

    $webClient = new-object Net.WebClient
    $webClient.Headers['User-Agent']="PowerShell/$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
    $webClient.Headers['CSRFPreventionToken']="$($pve.CSRFPreventionToken)"
    $webClient.Headers['Cookie']="PVEAuthCookie=$($pve.Ticket)"

    $callback = [Net.ServicePointManager]::ServerCertificateValidationCallback
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    if ($method -ne "Get") {
        if ($body -ne "") {
            $data = ConvertTo-Json $body
            $response = $webClient.UploadString($url, $method, $data)
        } else {
            $response = $webClient.UploadString($url, $method, $null)
        }
    } else {
        $response = $webClient.DownloadString($url) | ConvertFrom-Json
    }

    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $callback

    return $response
}

Function Get-NodeName {
    param (
        [psobject] $ProxmoxServer
    )

    if ($ProxmoxServer.ServerName.Contains('.')) {
        $parts = $ProxmoxServer.ServerName.Split('.')
        return $parts[0]
    }

    return $ProxmoxServer.ServerName
}

##################################################################################################

Function Get-PveServer {
<#
.SYNOPSIS
    Connect to the specified Proxmox server and return the tickets

.PARAMETER ServerName 
    The name of the Proxmox server to connect to

.PARMETER UserName
    The name of the user with credentials on server.

.PARMETER Password
    The password of the user with credentials on server.

.EXAMPLE     
    'VMHOST1' | Get-PveServer -UserName "root@pam" -Password "asdf" | Create-PveHost ...
    Connect to the specified proxmox server and creates a new VM.
       
.EXAMPLE     
    $pve = Get-PveServer -Server "VMHOST1" -UserName "root@pam" -Password "asdf"
    Get a connection to the specified proxmox server and store it in the $pve variable.

#Requires -Version 2.0
#>
	[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   Position=1)]   
        [string]$ServerName,                                   

        [Parameter(Position=2)]   
        [string]$UserName,

        [Parameter(Position=3)]   
        [string]$Password,

        [pscredential]$Credential
    )
    BEGIN { }
    PROCESS {
        if (-not ($UserName -or $Password)) {
            if (-not ($Credentials)) {
                $Credential = Get-Credential
            }

            $UserName = $Credential.UserName
            $Password = $Credential.GetNetworkCredential().Password
        }

        $Url = "https://$($ServerName):8006/api2/json/access/ticket"
        $Body = @{
            username = $UserName
            password = $Password
        }

        $callback = [Net.ServicePointManager]::ServerCertificateValidationCallback
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        $response = Invoke-RestMethod -Uri $url -Body $Body -Method Post
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $callback

        $pve = @{
            "ServerName" = $ServerName
            "CSRFPreventionToken" = $response.data.CSRFPreventionToken
            "Ticket" = $response.data.ticket
            "UserName" = $response.data.username
        }

        return $pve
    }
    END { } 
}

Function Get-PveVersion {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer
    )
    
    BEGIN {}
    PROCESS {
        $response = Get-ServerResponse -pve $ProxmoxServer -action "version"

        return "$($response.data.version).$($response.data.release)"
    }
    END {}
}

Function Get-PveStorage {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer,
        [string] $Id = ""
    )
    
    BEGIN {}
    PROCESS {
        $action = "storage"

        if ($Id -ne "") {
            $action = "$action/$id"
        }

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        return $response.data
    }
    END {}
}

Function Get-PveClusterNodes {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        return $response.data
    }
    END {}
}

Function Get-PveClusterStatus {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer
    )
    
    BEGIN {}
    PROCESS {
        $action = "cluster/resources"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        return $response.data
    }
    END {}
}

Function Get-PveClusterTasks {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer
    )
    
    BEGIN {}
    PROCESS {
        $action = "cluster/tasks"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        $tasks = @()

        $taskdata = $response.data | Sort-Object starttime | ForEach-Object {
            $task = @"
{
    "Start Time" : "$(ConvertFrom-UnixTime $_.starttime)",
    "End Time" : "$(ConvertFrom-UnixTime $_.endtime)",
    "Node" : "$($_.node)",
    "User" : "$($_.user)",
    "Description" : "$(if ($_.id) { "VM $($_.id) - " })$($_.type)",
    "Status" : "$($_.status)"
}
"@

            $tasks += ConvertFrom-Json $task
        }

        return $tasks
    }
    END {}
}

Function Get-PveContainerStatus {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer,
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/openvz"

        if ($Id) {
            $action = "$action/$Id/status/current"
        }

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        return $response.data
    }
    END {}
}

Function Get-PveMachineStatus {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $ProxmoxServer,
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu"

        if ($Id) {
            $action = "$action/$Id/status/current"
        }

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action

        return $response.data
    }
    END {}
}

Function Suspend-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/suspend"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

Function Resume-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/resume"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

Function Start-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/start"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

Function Stop-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/stop"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

Function Reset-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/reset"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

Function Shutdown-PveMachine {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]   
        [psobject] $ProxmoxServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $action = "nodes/$(Get-NodeName $ProxmoxServer)/qemu/$Id/status/shutdown"

        $response = Get-ServerResponse -pve $ProxmoxServer -action $action -method "Post"

        return $response.data
    }
    END {}
}

##################################################################################################

Export-ModuleMember Get-PveServer
Export-ModuleMember Get-PveVersion
Export-ModuleMember Get-PveStorage
Export-ModuleMember Get-PveClusterNodes
Export-ModuleMember Get-PveClusterStatus
Export-ModuleMember Get-PveClusterTasks
Export-ModuleMember Get-PveContainerStatus
Export-ModuleMember Get-PveMachineStatus
Export-ModuleMember Suspend-PveMachine
Export-ModuleMember Resume-PveMachine
Export-ModuleMember Start-PveMachine
Export-ModuleMember Stop-PveMachine
Export-ModuleMember Reset-PveMachine
Export-ModuleMember Shutdown-PveMachine
