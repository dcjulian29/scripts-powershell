function Connect-DockerContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "attach $Id"
}

function Get-DockerContainer {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = "Individual", Position = 0)]
        [string]$Id,
        [Parameter(ParameterSetName = "All")]
        [switch]$Running
    )

    if ($PSCmdlet.ParameterSetName -eq "Individual") {
        Invoke-Docker "inspect $Id" | ConvertFrom-Json
        return
    }

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

Set-Alias -Name docker-container -Value Get-DockerContainer

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
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = "Individual", Position = 0)]
        [string]$Id,
        [Parameter(ParameterSetName = "All")]
        [switch]$Running
    )

    if ($PSCmdlet.ParameterSetName -eq "Individual") {
        $container = Get-DockerContainer -Id $Id

        return $container.NetworkSettings.IPAddress
    }

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $arg += "--format {{.ID}} --no-trunc"

    $containers = Invoke-Docker $arg
    $containerList = @()

    if ($containers) {
        foreach ($containerId in $containers) {
            $item = New-Object -TypeName PSObject

            $ip = (Get-DockerContainer -Id $containerId).NetworkSettings.IPAddress

            $item | Add-Member -MemberType NoteProperty -Name Id -Value $containerId
            $item | Add-Member -MemberType NoteProperty -Name IpAddress -Value $ip

            $containerList += $item
        }
    }

    return $containerList
}

function Get-DockerContainerLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "container logs $Id"
}

function Get-DockerContainerNames {
    param (
        [switch]$Running,
        [Alias("IncludeImage")]
        [switch]$Image
    )

    $arg = "ps "

    if (-not $Running) {
        $arg += "--all "
    }

    $format = "--format {{.Names}}"

    if ($Image) {
        $format += ",{{.Image}}"
    }

    $arg += $format

    $output = Invoke-Docker $arg

    $list = @()

    foreach ($line in $output) {
        if ($Image) {
            $item = $line.Split(',')

            $detail = New-Object -TypeName PSObject

            $detail | Add-Member -MemberType NoteProperty -Name "Name" -Value $item[0]
            $detail | Add-Member -MemberType NoteProperty -Name "Image" -Value $item[1]

            $list += $detail
        } else {
            $list += $line
        }
    }

    return $list
}

function Get-DockerContainerState {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = "Individual", Position = 0)]
        [string]$Id,
        [Parameter(ParameterSetName = "All")]
        [switch]$Running
    )

    if ($PSCmdlet.ParameterSetName -eq "Individual") {
        $container = Get-DockerContainer -Id $Id

        return $container.State.Status
    }

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
    Get-DockerContainer -Running
}

function Remove-ExitedDockerContainers {
    (Get-DockerContainerState | Where-Object { $_.State -eq 'exited' }).Id | ForEach-Object {
        Invoke-Docker "rm -v $_"
    }
}

function Remove-NonRunningDockerContainers {
    (Get-DockerContainerState | Where-Object { $_.State -ne 'running' }).Id | ForEach-Object {
        Invoke-Docker "rm -v $_"
    }
}

function Start-DockerContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "start $Id"
}

function Stop-DockerContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [int]$TimeOut = 15
    )

    Invoke-Docker "stop $Id -t $TimeOut"
}
