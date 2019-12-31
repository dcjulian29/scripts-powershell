function Find-Docker {
    First-Path `
        (Find-ProgramFiles "Docker\Docker\Resources\bin\docker.exe")
}

function Get-DockerContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "inspect $Id" | ConvertFrom-Json
}

function Get-DockerContainerIds {
    param (
        [switch]$Running,
        [switch]$NoTruncate
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $arg += "--format {{.ID}} "

    if ($NoTruncate) {
        $arg += "--no-trunc"
    }

    Invoke-Docker $arg
}

function Get-DockerContainerIPAddress {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $container = Get-DockerContainer -Id $Id

    return $container.NetworkSettings.IPAddress
}

function Get-DockerContainerIPAddresses {
    param (
        [switch]$Running
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $arg += "--format {{.ID}} --no-trunc"

    $containers = Invoke-Docker $arg
    $containerList = @()

    if ($containers) {
        foreach ($containerId in $containers) {
            $container = New-Object -TypeName PSObject

            $container | Add-Member -MemberType NoteProperty -Name Id -Value $containerId
            $container | Add-Member -MemberType NoteProperty -Name IpAddress -Value $(Get-DockerContainerIPAddress $containerId)

            $containerList += $container
        }
    }

    return $containerList

}

function Get-DockerContainerNames {
    param (
        [switch]$Running,
        [switch]$Image
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    if ($Image) {
        $arg += "--format ""{{.Names}} container is using the '{{.Image}}' image"" "
    } else {
        $arg += "--format {{.Names}} "
    }

$arg
    Invoke-Docker $arg
}

function Get-DockerContainers {
    param (
        [switch]$Running
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $arg += "--no-trunc --size"
    $containers = Invoke-Docker $arg

    $containerList = @()

    if ($containers) {
        if ($containers.Length -gt 1) {
            foreach ($containerLine in $containers) {
                if ($containerLine.StartsWith("CONTAINER")) {
                    continue # Exclude Header Row
                }

                $result = $containerLine | Select-String -Pattern '(\S+(?:(?!\s{2}).)+)\s+' -AllMatches

                $container = New-Object -TypeName PSObject

                $container | Add-Member -MemberType NoteProperty -Name Id -Value $result.Matches[0].Value
                $container | Add-Member -MemberType NoteProperty -Name Image -Value $result.Matches[1].Value
                $container | Add-Member -MemberType NoteProperty -Name Command -Value  $result.Matches[2].Value
                $container | Add-Member -MemberType NoteProperty -Name Created -Value $result.Matches[3].Value
                $container | Add-Member -MemberType NoteProperty -Name Status -Value $result.Matches[4].Value

                if ($result.Matches.Length -eq 8) {
                    $ports = $result.Matches[5].Value
                    $name = $result.Matches[6].Value
                    $size = $result.Matches[7].Value
                } else {
                    $ports = $null
                    $name = $result.Matches[5].Value
                    $size = $result.Matches[6].Value
                }

                $container | Add-Member -MemberType NoteProperty -Name Ports -Value $ports

                $container | Add-Member -MemberType NoteProperty -Name Name -Value $name

                $size = $size.Substring(0, $size.IndexOf(' ')).ToUpper()
                $size -match '[A-Za-z]+' | Out-Null
                $size = [double]::Parse($size -replace '[^0-9.]')
                switch ($Matches[0]) {
                    "KB" { $size = $size * 1KB }
                    "MB" { $size = $size * 1MB }
                    "GB" { $size = $size * 1GB }
                    "TB" { $size = $size * 1TB }
                }

                $size = [int][Math]::Round($size, 0, [MidPointRounding]::AwayFromZero)

                $container | Add-Member -MemberType NoteProperty -Name Size -Value $size

                $containerList += $container
            }
        }
    }

    return $containerList
}

function Get-DockerContainerState {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    $container = Get-DockerContainer -Id $Id

    return $container.State.Status
}

function Get-DockerContainerStates {
    param (
        [switch]$Running
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $arg += "--format {{.ID}} --no-trunc"

    $containers = Invoke-Docker $arg
    $containerList = @()

    if ($containers) {
        foreach ($containerId in $containers) {
            $container = New-Object -TypeName PSObject

            $container | Add-Member -MemberType NoteProperty -Name Id -Value $containerId
            $container | Add-Member -MemberType NoteProperty -Name State -Value $(Get-DockerContainerState $containerId)

            $containerList += $container
        }
    }

    return $containerList

}

function Get-RunningDockerContainers {
    Get-DockerContainers -Running
}

function Invoke-Docker {
    cmd /c """$(Find-Docker)"" $args"
}

function Remove-ExitedDockerContainers {
    (Get-DockerContainerStates | Where-Object { $_.State -eq 'exited' }).Id | ForEach-Object {
        Invoke-Docker "rm -v $_"
    }
}

function Remove-NonRunningDockerContainers {
    (Get-DockerContainerStates | Where-Object { $_.State -ne 'running' }).Id | ForEach-Object {
        Invoke-Docker "rm -v $_"
    }
}

function Start-DockerContainer {
    param (
        [string]$Id
    )

    Invoke-Docker "start $Id"
}

function Stop-DockerContainer {
    param (
        [string]$Id,
        [int]$TimeOut = 15
    )

    Invoke-Docker "stop $Id -t $TimeOut"
}
