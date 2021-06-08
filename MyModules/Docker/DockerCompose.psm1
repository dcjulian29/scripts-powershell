function Build-DockerCompose {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias("Path")]
        [string]$ComposeFile = "docker-compose.yml"
    )

    Invoke-DockerCompose "-f $ComposeFile build"
}

Set-Alias -Name "dcb" -Value "Build-DockerCompose"

function Find-DockerCompose {
    First-Path `
        ((Get-Command 'docker-compose.exe' -ErrorAction SilentlyContinue).Source) `
        (Find-ProgramFiles "Docker\Docker\Resources\bin\docker-compose.exe")
}

function Get-DockerComposeLog {
    Invoke-DockerCompose "logs"
}

function Invoke-DockerCompose {
    $docker = Find-DockerCompose

    if ($docker) {
        if (Test-DockerCompose) {
            cmd /c """$docker"" $args"
        } else {
            throw "Docker Compose is not installed on this system."
        }
    }
}

Set-Alias -Name "dc" -Value "Invoke-DockerCompose"

function Invoke-DockerComposeLog {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ContainerName
    )

    Invoke-DockerCompose "logs $ContainerName"
}

Set-Alias -Name "dcl" -Value "Invoke-DockerComposeLog"
Set-Alias -Name "dclog" -Value "Invoke-DockerComposeLog"

function Invoke-DockerComposeLogTail {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ContainerName,
        [int] $Lines = 50
    )

    Invoke-DockerCompose "logs -tf --tail=$Lines $ContainerName"
}

Set-Alias -Name "dctail" -Value "Invoke-DockerComposeLogTail"

function Pop-DockerCompose {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias("Path")]
        [string]$ComposeFile = "docker-compose.yml"
    )

    Invoke-DockerCompose "-f $ComposeFile pull"
}

Set-Alias -Name "Pull-DockerCompose" -Value "Pop-DockerCompose"
Set-Alias -Name "dcpull" -Value "Pop-DockerCompose"

function Read-DockerCompose {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias("Path")]
        [string]$ComposeFile = "docker-compose.yml"
    )

    Invoke-DockerCompose "-f $ComposeFile config"
}

Set-Alias -Name "Validate-DockerCompose" -Value "Read-DockerCompose"

function Resume-DockerCompose {
    Invoke-DockerCompose "start"
}

function Start-DockerCompose {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Alias("Path")]
        [string]$ComposeFile = "docker-compose.yml"
    )

    Invoke-DockerCompose "-f $ComposeFile up -d"
}

Set-Alias -Name "dcu" -Value "Start-DockerCompose"
Set-Alias -Name "dcup" -Value "Start-DockerCompose"

function Stop-DockerCompose {
    Invoke-DockerCompose "down"
}

Set-Alias -Name "dcd" -Value "Stop-DockerCompose"
Set-Alias -Name "dcdown" -Value "Stop-DockerCompose"

function Suspend-DockerCompose {
    Invoke-DockerCompose "stop"
}

function Test-DockerCompose {
    $docker = Find-DockerCompose

    if ($docker) {
        if (Test-Path $docker) {
            return $true
        } else {
            return $false
        }
    }
}
