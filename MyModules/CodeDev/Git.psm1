$script:GIT_INSTALL_ROOT = Find-ProgramFiles "Git\bin"
$script:GIT = "${script:GIT_INSTALL_ROOT}\git.exe"
$script:DEV_TOOLS_ROOT = "${env:SYSTEMDRIVE}\tools\development"

if (Test-Path "$GIT_INSTALL_ROOT") {
    $env:Path = "$env:Path;$GIT_INSTALL_ROOT"

    if (Test-Path "$($env:UserProfile)\Documents\WindowsPowerShell\Modules\posh-git") {
        Import-Module Posh-Git

        Enable-GitColors

        $GitPromptSettings.BeforeText = "["
    }
}

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

Function Backup-GitRepository {
    & "$DEV_TOOLS_ROOT\git-backup.bat"
}

Function Remove-GitRepositoryBackup {
    & "$DEV_TOOLS_ROOT\git-backup-remove.bat"
}

Function Push-GitRepository {
    & "$GIT" push
    & "$GIT" push --tags
}

Function Pull-GitRepository {
    & "$GIT" fetch --all
    & "$GIT" pull
}

Function Fetch-GitRepository {
    & "$GIT" fetch --all
}

Function Get-GitRepositoryStatus {
    & "$GIT" status
}

Function Push-GitRepositoriesThatAreTracked {
    # TODO: Added support for additional "remote" repositories
    $remoteRepositories = @("origin")

    foreach ($remote in $remoteRepositories) {
        $remoteInfo = Invoke-Expression "& '$GIT' remote show origin"

        foreach ($line in $remoteInfo) {
            if ($line -match "\W*(.+) pushes to .+") { 
                "Pushing {0}/{1}..." -f $remote, $Matches[1]
                Invoke-Expression $("& '{0}' push {1} {2}" -f $GIT, $remote, $Matches[1])
            }
        }
    }

    "Pushing tags..."
    & "$GIT" push --tags
}

###################################################################################################

Export-ModuleMember Get-GitIgnore
Export-ModuleMember Add-GitIgnore
Export-ModuleMember Backup-GitRepository
Export-ModuleMember Remove-GitRepositoryBackup
Export-ModuleMember Pull-GitRepository
Export-ModuleMember Push-GitRepository
Export-ModuleMember Fetch-GitRepository
Export-ModuleMember Get-GitRepositoryStatus
Export-ModuleMember Push-GitRepositoriesThatAreTracked

Set-Alias gb Backup-GitRepository
Export-ModuleMember -Alias gb

Set-Alias gbr Remove-GitRepositoryBackup
Export-ModuleMember -Alias gbr

Set-Alias gpull Pull-GitRepository
Export-ModuleMember -Alias gpull

Set-Alias gpush Push-GitRepository
Export-ModuleMember -Alias gpush

Set-Alias gpushall Push-GitRepositoriesThatAreTracked
Export-ModuleMember -Alias gpushall

Set-Alias gfetch Fetch-GitRepository
Export-ModuleMember -Alias gfetch

Set-Alias gs Get-GitRepositoryStatus
Export-ModuleMember -Alias gs
