function convertSizeString($Size) {
    if ($Size.Contains(' ')) {
        $size = $size.Substring(0, $size.IndexOf(' '))
    }

    $size = $size.ToUpper()
    $size -match '[A-Za-z]+' | Out-Null
    $size = [double]::Parse($size -replace '[^0-9.]')
    switch ($Matches[0]) {
        "KB" { $size = $size * 1KB }
        "MB" { $size = $size * 1MB }
        "GB" { $size = $size * 1GB }
        "TB" { $size = $size * 1TB }
    }

    $size = [int][Math]::Round($size, 0, [MidPointRounding]::AwayFromZero)

    return $size
}

#-----------------------------------------------------------------------------

function Find-Docker {
    First-Path `
        ((Get-Command docker -ErrorAction SilentlyContinue).Source) `
        "${env:ALLUSERSPROFILE}\DockerDesktop\version-bin\docker.exe" `
        (Find-ProgramFiles "Docker\Docker\Resources\bin\docker.exe")
}

function Get-DockerDiskUsage {
    $output = Invoke-Docker "system df"

    $list = @()

    if ($output) {
        foreach ($line in $output) {
            if ($line.StartsWith("TYPE")) {
                continue # Exclude Header Row
            }

            $result = $line | Select-String -Pattern '(\S+\s\S+|\S+)' -AllMatches

            $detail = New-Object -TypeName PSObject

            $detail | Add-Member -MemberType NoteProperty -Name Type -Value $result.Matches[0].Value
            $detail | Add-Member -MemberType NoteProperty -Name Total -Value $result.Matches[1].Value
            $detail | Add-Member -MemberType NoteProperty -Name Active -Value $result.Matches[2].Value
            $detail | Add-Member -MemberType NoteProperty -Name Size `
                -Value $(convertSizeString $result.Matches[3].Value)
            $detail | Add-Member -MemberType NoteProperty -Name Reclaimable `
                -Value $(convertSizeString $result.Matches[4].Value)

            $list += $detail
        }
    }

    return $list
}

Set-Alias -Name docker-diskusage -Value Get-DockerDiskUsage

function Get-DockerServerEngine {
    $version = Invoke-Docker "version"

    if (-not $version) {
        return $null
    }

    $server = $false

    foreach ($line in $version) {
        if ($line -like "Server:*") {
            $server = $true
        }

        if ($server) {
            if ($line -like "*OS/Arch:*") {
                return ($line.split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))[1]
            }
        }
    }
}

function Invoke-AlpineContainer {
    if (Test-DockerLinuxEngine) {
        New-DockerContainer -Image "alpine" -Tag "latest" -Interactive -Name "alpine_shell"
    } else {
        Write-Error "Alpine Linux requires the Linux Docker Engine!" -Category ResourceUnavailable
    }
}

Set-Alias -Name alpine -Value Invoke-AlpineContainer

function Invoke-DebainContainer {
    if (Test-DockerLinuxEngine) {
        New-DockerContainer -Image "debian" -Tag "buster-slim" -Interactive -Name "debian_shell"
    } else {
        Write-Error "Debian Linux requires the Linux Docker Engine!" -Category ResourceUnavailable
    }
}

Set-Alias -Name debian -Value Invoke-DebianContainer

function Invoke-Docker {
    $docker = Find-Docker

    if ($docker) {
        if (Test-Docker) {
            cmd /c """$docker"" $args"
        } else {
            throw "Docker is not installed on this system."
        }
    }
}

function Optimize-Docker {
    param (
        [switch]$Force
    )

    $params = "--all"

    if ($Force) {
        $params += " --force"
    }

    Invoke-Docker "system prune"
}

Set-Alias -Name Prune-Docker -Value Optimize-Docker
Set-Alias -Name docker-prune -Value Optimize-Docker

function Switch-DockerLinuxEngine {
    if (-not (Test-DockerLinuxEngine)) {
        & "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine
    }
}

function Switch-DockerWindowsEngine {
    if (-not (Test-DockerWindowsEngine)) {
        & "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchWindowsEngine
    }
}

function Test-Docker {
    $docker = Find-Docker

    if ($docker) {
        if (Test-Path $docker) {
            return $true
        } else {
            return $false
        }
    }
}

function Test-DockerLinuxEngine {
    if ((Get-DockerServerEngine) -like '*linux*') {
        return $true
    }

    return $false
}

function Test-DockerWindowsEngine {
    if ((Get-DockerServerEngine) -like '*windows*') {
        return $true
    }

    return $false
}
