Function Get-GitIgnore {
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

Function Add-GitIgnore {
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

    $content = Get-GitIgnore $Template

    if ($content) {
        Out-File -Encoding UTF8 -Filepath .gitignore -NoClobber -InputObject $content
    }
}

Export-ModuleMember Get-GitIgnore
Export-ModuleMember Add-GitIgnore
