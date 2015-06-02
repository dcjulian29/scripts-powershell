$script:GIT_INSTALL_ROOT = Find-ProgramFiles "Git\bin"
$script:GIT = "${script:GIT_INSTALL_ROOT}\git.exe"

if (-not ([String]::IsNullOrWhiteSpace($script:GIT_INSTALL_ROOT))) {
    if (Test-Path "$script:GIT_INSTALL_ROOT") {
        $env:Path = "$env:Path;$script:GIT_INSTALL_ROOT"

        if (Test-Path "$($env:UserProfile)\Documents\WindowsPowerShell\Modules\posh-git") {
            Import-Module Posh-Git

            Enable-GitColors

            $GitPromptSettings.BeforeText = "["
        }
    }
}

Function Add-GitIgnoreToLocalRepository {
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

Function Add-GitIgnoreToRemoteRepository {
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

Function Get-GitIgnoreTemplate {
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

Function Add-GitIgnoreTemplate {
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
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string] $Path = $pwd
    )

    if (-not (Test-Path "$(Join-Path $Path ".git")")) {
        Write-Warning "This directory is not the root of a GIT repository."
        return
    }

    $timestamp = [DateTime]::Now.ToString("yyyyMMdd")
    $project = Split-Path -Leaf $Path

    $backup = Join-Path $env:TEMP "$project-backup-$timestamp"

    if (Test-Path $backup) {
        Write-Error "This project already has a backup for today, please delete the backup and try again."
        return
    }

    Write-Output "Backing up $project..."

    New-Item -ItemType Directory -Path $backup | Out-Null

    & robocopy.exe "$Path" "$backup" /MIR /Z /SL /MT /XJ /R:5 /W:5
}

Function Remove-GitRepositoryBackup {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string] $Path = $pwd
    )

    if (-not (Test-Path "$(Join-Path $Path ".git")")) {
        Write-Warning "This directory is not the root of a GIT repository."
        return
    }

    $project = Split-Path -Leaf $Path

    $backup = Get-ChildItem -Path $env:TEMP | Where-Object { $_.PSIsContainer } `
        | Where-Object { $_.Name -like "$project-backup-*" } | Select-Object FullName

    $foobar = Get-ChildItem -Path $env:TEMP | Where-Object { $_.PSIsContainer } `
        | Where-Object { $_.Name -like "$project-foobar-*" } | Select-Object FullName
    
    foreach ($folder in $backup) {
        Write-Output "Removing backup at $($folder.FullName)"
        Remove-Item -Path $folder.FullName -Recurse -Force
    }

    foreach ($folder in $foobar) {
        Write-Output "Removing foobar copy at $($folder.FullName)"
        Remove-Item -Path $folder.FullName -Recurse -Force
    }
}

Function Restore-GitRepositoryBackup {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string] $Path = $pwd
    )

    if (-not (Test-Path "$(Join-Path $Path ".git")")) {
        Write-Warning "This directory is not the root of a GIT repository."
        return
    }

    $timestamp = [DateTime]::Now.ToString("yyyyMMdd")
    $project = Split-Path -Leaf $Path

    $backup = Join-Path $env:TEMP "$project-backup-$timestamp"
    $foobar = Join-Path $env:TEMP "$project-foobar-$timestamp"

    if (-not (Test-Path $backup)) {
        Write-Error "This project does not contain a backup for today."
        return
    }

    New-Item -ItemType Directory -Path $foobar | Out-Null

    & robocopy.exe "$Path" "$foobar" /MIR /Z

    Remove-Item -Path "$Path\*" -Recurse -Force

    Write-Output "Restoring from $project backup..."

    & robocopy.exe "$backup" "$Path" /MIR /Z
}

Function Push-GitRepository {
    $remote = & "$GIT" remote
    "Pushing to $remote..."
    & "$GIT" push
    "Pushing tags..."
    & "$GIT" push --tags
}

Function Pull-GitRepository {
    Fetch-GitRepository
    & "$GIT" pull
}

Function Fetch-GitRepository {
    & "$GIT" fetch --prune --all
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

Function Publish-GitRepositoryToQA {

    $tag = & $GIT lasttag
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish $tag to QA on $date"

    & "$GIT" checkout qa

    & "$GIT" merge --no-ff master -m $commit
}

Function Publish-GitRepositoryToUAT {
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish QA to UAT on $date"

    & "$GIT" checkout uat

    & "$GIT" merge --no-ff qa -m $commit
}

Function Publish-GitRepositoryToPROD {
    param (
        [switch] $FromUAT,
        [switch] $FromQA
    )
    
    if ($FromUAT -and $FromQA) {
        throw "You cannot publish from both environments."
    }
    
    if ( -not ($FromUAT -or $FromQA) {
        throw "You must select an environment to publish from."
    }
    
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    & "$GIT" checkout prod

    if ($FromQA) {
        $commit = "Publish QA to Production on $date"
        & "$GIT" merge --no-ff qa -m $commit
    } else {
        $commit = "Publish UAT to Production on $date"    
        & "$GIT" merge --no-ff uat -m $commit
    }
}

Function Update-AllGitRepositories {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string] $Path = $pwd
    )

    Write-Output "Updating from remote repository for GIT projects in this directory..."

    $folders = Get-ChildItem -Path $Path | Where-Object { $_.PSIsContainer }

    foreach ($folder in $folders) {
        if (Test-Path "$(Join-Path $folder.FullName ".git")") {
            Write-Output "== $($folder.Name)"
            Push-Location $folder.FullName
            & "$GIT" remote -v
            & "$GIT" fetch --all
            Pop-Location
            Write-Output ""
        }
    }
}

###################################################################################################

Export-ModuleMember Add-GitIgnoreToLocalRepository
Export-ModuleMember Add-GitIgnoreToRemoteRepository
Export-ModuleMember Get-GitIgnoreTemplate
Export-ModuleMember Add-GitIgnoreTemplate
Export-ModuleMember Backup-GitRepository
Export-ModuleMember Remove-GitRepositoryBackup
Export-ModuleMember Restore-GitRepositoryBackup
Export-ModuleMember Pull-GitRepository
Export-ModuleMember Push-GitRepository
Export-ModuleMember Fetch-GitRepository
Export-ModuleMember Get-GitRepositoryStatus
Export-ModuleMember Push-GitRepositoriesThatAreTracked
Export-ModuleMember Publish-GitRepositoryToQA
Export-ModuleMember Publish-GitRepositoryToUAT
Export-ModuleMember Publish-GitRepositoryToPROD
Export-ModuleMember Update-AllGitRepositories

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
