function Add-GitIgnoreTemplate {
    <#
    .Synopsis
        Add the requested .gitignore to current directory.
    .Description
        Command will create .gitignore file for specific template and put it to the current folder.
    #>

    Param (
        [Parameter(Position = 0, Mandatory=$true, HelpMessage="Template Name")]
        [ValidateNotNullOrEmpty()]
        [string] $Template
    )

    $content = Get-GitIgnoreTemplate $Template

    if ($content) {
        Out-File -Encoding UTF8 -Filepath .gitignore -NoClobber -InputObject $content
    }
}

function Add-GitIgnoreToLocalRepository {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string] $Pattern,
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd
    )

    if (-not (Test-Path "$(Join-Path $Path ".git")")) {
        Write-Warning "This directory is not the root of a GIT repository."
        return
    }

    $ignore = [System.IO.Path]::Combine($Path, ".git", "info", "exclude")
    Add-Content -Path $ignore -Value "$Pattern"
}

function Add-GitIgnoreToRemoteRepository {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string] $Pattern,
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd
    )

    if (-not (Test-Path "$(Join-Path $Path ".git")")) {
        Write-Warning "This directory is not the root of a GIT repository."
        return
    }

    $ignore = [System.IO.Path]::Combine($Path, ".gitignore")

    if (-not (Test-Path $ignore)) {
        Set-Content -Path $ignore -Value "$Pattern"
    } else {
        Add-Content -Path $ignore -Value "$Pattern"
    }
}

function Get-GitIgnoreTemplate {
    <#
    .Synopsis
        Displays list of supported templates.
    .Description
        Command will download list of supported .gitignore file from github.
    #>

    Param (
        [Parameter(Position = 0, Mandatory=$false, HelpMessage="Template Name")]
        [string] $Template
    )

    $webClient = new-object Net.WebClient
    $webClient.Headers['User-Agent']='PowerShell/$(PSVersionTable.PSVersion.Major).$(PSVersion.PSVersion.Minor)'

    if ($Template) {
        try {
            $webClient.DownloadString("https://api.github.com/gitignore/templates/$Template") | ConvertFrom-Json | Select-Object -ExpandProperty source
        } catch [Exception] {
            Write-Error "Template '$Template' not found"
        }
    } else {
        $webClient.DownloadString("https://api.github.com/gitignore/templates") | ConvertFrom-Json
    }
}
