function Connect-DockerNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $NetworkName,
        [Parameter(Mandatory = $true)]
        [string] $ContainerName,
        [string] $IPv4,
        [string] $IPv6,
        [string[]] $Aliases
    )

    $options = ""
    if ($IPv4) {
        $options += " --ip $IPv4"
    }

    if ($IPv6) {
        $options += " --ip6 $IPv6"
    }

    if ($Aliases) {
        foreach ($alias in $Aliases) {
            $options += " --alias $alias"
        }
    }

    $params = "network connect$options $NetworkName $ContainerName"

    Invoke-Docker $params
}

function Disconnect-DockerNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $NetworkName,
        [Parameter(Mandatory = $true)]
        [string] $ContainerName,
        [switch] $Force
    )

    $params = "network disconnect"

    if ($Force) {
        $params += " --force"
    }

    $params += " $NetworkName $ContainerName"

    Invoke-Docker $params
}

function Get-DockerNetwork {
    [CmdletBinding()]
    param (
        [string] $Name
    )

    if ($Name.Length -eq 0) {
        $net = Invoke-Docker network ls --no-trunc
        $list = @()

        foreach ($line in $net) {
            if ($line.StartsWith("NETWORK")) {
                continue
            }

            $result = $line | Select-String -Pattern '(\S+)\s\s+(\S+)\s+(\S+)\s+(\S+)'

            $network = New-Object -TypeName PSObject

            $network | Add-Member -MemberType NoteProperty -Name Id -Value $result.Matches.Groups[1].Value
            $network | Add-Member -MemberType NoteProperty -Name Name -Value $result.Matches.Groups[2].Value
            $network | Add-Member -MemberType NoteProperty -Name Driver -Value $result.Matches.Groups[3].Value
            $network | Add-Member -MemberType NoteProperty -Name Scope -Value $result.Matches.Groups[4].Value

            $list += $network
        }

        return $list
    } else {
        $json = Invoke-Docker network inspect $Name

        return $json | ConvertFrom-Json
    }
}

function New-DockerNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    Invoke-Docker network create $Name
}

function Optimize-DockerNetwork {
    param (
        [switch] $Force
    )

    $params = "network prune"

    if ($Force) {
        $params += " --force"
    }

    Invoke-Docker $params
}

Set-Alias -Name Prune-DockerNetwork -Value Optimize-DockerNetwork

function Remove-DockerNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    Invoke-Docker network rm $Name
}
