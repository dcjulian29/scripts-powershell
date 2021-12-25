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

                $container | Add-Member -MemberType NoteProperty -Name Id -Value $result.Matches[0].Value.Trim()
                $container | Add-Member -MemberType NoteProperty -Name Image -Value $result.Matches[1].Value.Trim()
                $container | Add-Member -MemberType NoteProperty -Name Command -Value  $result.Matches[2].Value.Trim()
                $container | Add-Member -MemberType NoteProperty -Name Created -Value $result.Matches[3].Value.Trim()
                $container | Add-Member -MemberType NoteProperty -Name Status -Value $result.Matches[4].Value.Trim()

                if ($result.Matches.Length -eq 8) {
                    $ports = $result.Matches[5].Value.Trim()
                    $name = $result.Matches[6].Value.Trim()
                    $size = $result.Matches[7].Value.Trim()
                } else {
                    $ports = $null
                    $name = $result.Matches[5].Value.Trim()
                    $size = $result.Matches[6].Value.Trim()
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

function Invoke-DockerContainerShell {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "exec -it $Id /bin/sh"
}

function Invoke-DockerLog {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ContainerName
    )

    Invoke-Docker "logs $ContainerName"
}

Set-Alias -Name "dlog" -Value "Invoke-DockerLog"

function Invoke-DockerLogTail {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ContainerName,
        [int] $Lines = 50
    )

    Invoke-Docker "logs -tf --tail=$Lines $ContainerName"
}

Set-Alias -Name "dtail" -Value "Invoke-DockerLogTail"

function New-DockerContainer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position = 0)]
        [string]$Image,
        [Parameter(Position = 1)]
        [string]$Tag = "latest",
        [string]$Name,
        [string]$HostName,
        [string[]]$Volume,
        [switch]$ReadOnly,
        [string]$EntryPoint,
        [string]$Command,
        [switch]$Interactive,
        [switch]$Keep
    )

    $param = "run"

    if ($Interactive) {
        $param += " --interactive --tty"
    } else {
        $param += " --detach"
    }

    if (-not $Keep) {
        $param += " --rm"
    }

    if ($HostName) {
        $param += " --hostname $HostName"
    }

    if ($Name) {
        $param += " --name $Name"
    }

    if ($EntryPoint) {
        $param += " --entrypoint `"$EntryPoint`""
    }

    if ($ReadOnly) {
        $param += " --read-only"
    }

    # Future Enhancements:
    # "--env [string[]]$EnvironmentVariables" #Maybe HashTable?
    # "--expose list   (port mapping)"
    # "--network list"

    if (($Volume) -and ($Volume.Count -gt 0)) {
      for ($i = 0; $i -lt $Volume.Count; $i++) {
        $param += " --volume $($Volume[$i])"
      }
    }

    $param += " ${Image}:$Tag"

    if ($Command) {
        $param += " `"$Command`""
    }

    $param = $param.Trim()

    Write-Verbose $param
    Invoke-Docker $param
}

function Remove-DockerContainer {
    [CmdletBinding(DefaultParameterSetName="ID")]
    param (
        [Parameter(ParameterSetName="Container", ValueFromPipeline=$true)]
        [psobject] $Container,
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "ID", ValueFromPipeline = $true)]
        [Alias("Name")]
        [string]$Id,
        [Parameter(ParameterSetName = "All")]
        [switch]$All,
        [Parameter(ParameterSetName = "Other")]
        [switch]$Exited,
        [Parameter(ParameterSetName = "Other")]
        [switch]$NonRunning
    )
    if ($PSCmdlet.ParameterSetName -eq "ID") {
      if ($Id.Length -gt 0) {
        Invoke-Docker "rm --volumes --force $Id"
      }
    }

    if ($PSCmdlet.ParameterSetName -eq "Container") {
      if ($Container.Id.Length -gt 0) {
        Invoke-Docker "rm --volumes --force $($Container.Id)"
      }
    }

    if ($PSCmdlet.ParameterSetName -eq "All") {
        Invoke-Docker "rm $(Invoke-Docker ps -a -q)"
    }

    if ($PSCmdlet.ParameterSetName -eq "Other") {
        if ($Exited) {
            (Get-DockerContainerState | Where-Object { $_.State -eq 'exited' }).Id | `
                ForEach-Object {
                  Invoke-Docker "rm  --volumes --force $_"
                }
        }

        if ($NonRunning) {
            (Get-DockerContainerState | Where-Object { $_.State -ne 'running' }).Id | `
              ForEach-Object {
                Invoke-Docker "rm  --volumes --force $_"
              }
        }
    }
}

function Start-DockerContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Id
    )

    Invoke-Docker "start $Id"
}

function Start-LinuxServerCommunityContainer {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Image,
        [string] $Name = $(((New-Guid).GUID).Replace('-','')),
        [string[]] $Volumes,
        [string[]] $Ports
    )

    $param = "run --rm -d --name=`"$Name`""

    foreach ($volume in $Volumes) {
        $param += " -v `"$volume`""
    }

    if ($param -like "-v *:/config`"*") {
        $param += " -v `"$(ConvertTo-UnixPath $PWD):/config`""
    }

    $param += " -e PUID=1000 -e PGID=1000"

    if ($Ports) {
        foreach ($port in $Ports) {
            $param += " -p $port"
        }
    }

    $param += " linuxserver/$Image"

    Invoke-Docker $param
}

Set-Alias -Name "docker-linuxserverio" -Value "Start-LinuxServerCommunityContainer"
Set-Alias -Name "docker-lsio" -Value "Start-LinuxServerCommunityContainer"

function Stop-DockerContainer {
    [CmdletBinding(DefaultParameterSetName="ID")]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "ID")]
        [Alias("Name")]
        [string]$Id,
        [Parameter(Position = 0, ParameterSetName = "All")]
        [Parameter(Position = 1, ParameterSetName = "ID")]
        [int]$TimeOut = 15,
        [Parameter(ParameterSetName = "All")]
        [switch]$All
    )

    if ($PSCmdlet.ParameterSetName -eq "ID") {
        Invoke-Docker "stop $Id -t $TimeOut"
    } else {
        Invoke-Docker "stop $(Invoke-Docker ps -a -q)"
    }
}
