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
        (Find-ProgramFiles "Docker\Docker\Resources\bin\docker.exe") `
        "${env:ALLUSERSPROFILE}/DockerDesktop/version-bin/docker.exe"
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

function Invoke-AlpineContainer {
    if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
        cmd.exe /c "docker.exe run -it alpine:latest"
    } else {
        throw "Docker is not installed on this system."
    }
}

Set-Alias -Name alpine -Value Invoke-AlpineContainer

function Invoke-Docker {
    cmd /c """$(Find-Docker)"" $args"
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
