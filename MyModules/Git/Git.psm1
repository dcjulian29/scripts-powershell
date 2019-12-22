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

    $content = Get-GitIgnoreTemplate $Template

    if ($content) {
        Out-File -Encoding UTF8 -Filepath .gitignore -NoClobber -InputObject $content
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

Set-Alias gb Backup-GitRepository

function Find-Git {
    "$(Find-ProgramFiles "Git")\bin\git.exe"
}

function Find-GraphicalGit {
    "$(Find-ProgramFiles "Git")\bin\gitk.exe"
}

Function Get-GitBranchesThatAreLocal {
    & "$(Find-Git)" for-each-ref --sort refname --format='%(refname:short)' refs/heads
}

Function Get-GitBranchesThatAreRemote {
    & "$(Find-Git)" for-each-ref --sort refname --format='%(refname:short)' refs/remotes
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

Function Get-GitRepositoryStatus {
    & "$(Find-Git)" status
}

Set-Alias gs Get-GitRepositoryStatus

Function Invoke-FetchGitRepository {
    & "$(Find-Git)" fetch --prune --all
}

Set-Alias Fetch-GitRepository Invoke-FetchGitRepository
Set-Alias gfetch Invoke-FetchGitRepository

Function Invoke-PullGitRepository {
    Fetch-GitRepository
    & "$(Find-Git)" pull
}

Set-Alias Pull-GitRepository Invoke-PullGitRepository
Set-Alias gpull Invoke-PullGitRepository

Function Optimize-AllGitRepositories {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd
    )

    Write-Output "Cleaning all GIT repositories in this directory..."

    $folders = Get-ChildItem -Path $Path | Where-Object { $_.PSIsContainer }

    foreach ($folder in $folders) {
        if (Test-Path "$(Join-Path $folder.FullName ".git")") {
            Write-Output "== $($folder.Name)"
            Push-Location $folder.FullName
            & "$(Find-Git)" gc
            Pop-Location
            Write-Output ""
        }
    }
}

Set-Alias git-gc-all Optimize-AllGitRepositories

Function Publish-GitRepositoryToPROD {
    [CmdletBinding(DefaultParameterSetName="QA")]
    param (
        [Parameter(ParameterSetName="UAT")]
        [switch] $FromUAT,
        [Parameter(ParameterSetName="QA")]
        [switch] $FromQA
    )

    if ( -not ($FromUAT -or $FromQA)) {
        throw "You must select an environment to publish from."
    }

    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    & "$(Find-Git)" checkout prod

    if ($FromQA) {
        $commit = "Publish QA to Production on $date"
        & "$(Find-Git)" merge --no-ff qa -m $commit
    } else {
        $commit = "Publish UAT to Production on $date"
        & "$(Find-Git)" merge --no-ff uat -m $commit
    }
}

Function Publish-GitRepositoryToQA {

    $tag = & $(Find-Git) lasttag
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish $tag to QA on $date"

    & "$(Find-Git)" checkout qa

    & "$(Find-Git)" merge --no-ff master -m $commit
}

Function Publish-GitRepositoryToUAT {
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish QA to UAT on $date"

    & "$(Find-Git)" checkout uat

    & "$(Find-Git)" merge --no-ff qa -m $commit
}

Function Push-GitRepositoriesThatAreTracked {
    # TODO: Added support for additional "remote" repositories
    $remoteRepositories = @("origin")

    foreach ($remote in $remoteRepositories) {
        $remoteInfo = Invoke-Expression "& '$(Find-Git)' remote show origin"

        foreach ($line in $remoteInfo) {
            if ($line -match "\W*(.+) pushes to .+") {
                "Pushing {0}/{1}..." -f $remote, $Matches[1]
                Invoke-Expression $("& '{0}' push {1} {2}" -f $(Find-Git), $remote, $Matches[1])
            }
        }
    }

    "Pushing tags..."
    & "$(Find-Git)" push --tags
}

Set-Alias gpushall Push-GitRepositoriesThatAreTracked

Function Push-GitRepository {
    $remote = & "$(Find-Git)" remote
    "Pushing to $remote..."
    & "$(Find-Git)" push
    "Pushing tags..."
    & "$(Find-Git)" push --tags
}

Set-Alias gpush Push-GitRepository

Function Remove-AllGitChanges {
    & "$(Find-Git)" reset HEAD
    & "$(Find-Git)" stash save --keep-index
    & "$(Find-Git)" stash drop
}

Function Remove-GitChanges {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_})]
        [string] $File
    )

    & "$(Find-Git)" checkout $File
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

Set-Alias gbr Remove-GitRepositoryBackup

Function Remove-LastGitCommit {
    if ($(& "$(Find-Git)" diff --exit-code) -and $(& "$(Find-Git)" diff --cached --exit-code)) {
        & "$(Find-Git)" reset --soft HEAD~1
    } else {
        Write-Warning "Commit is already pushed... You will need to revert the changes instead."
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

Function Show-AllGitInformation {
    Get-ChildItem -Directory | ForEach-Object {
        if (Test-Path "$(Join-Path $_.FullName ".git")") {
            Push-Location $_.FullName
            Write-Output "== $($_.Name)"
            & "$(Find-Git)" status
            Pop-Location
        } else {
            Write-Output "-- $($_.Name)"
        }

        Write-Output ""
    }
}

Set-Alias status-all-projects Show-AllGitInformation

Function Show-GitInformation {
    if (Test-Path "$(Join-Path $pwd.Path ".git")") {
        Write-Output "== Remote URLs:"
        & "$(Find-Git)" remote -v
        Write-Output ""

        Write-Output "== Branches:"
        & "$(Find-Git)" branch -a
        Write-Output ""

        Write-Output "== Configuration:"
        & "$(Find-Git)" config --local --list
        Write-Output ""

        Write-Output "== Most Recent Commit"
        & "$(Find-Git)" --no-pager log --max-count=1
        Write-Output ""

        Write-Output "Type 'git log' for more commits, or 'git show' for full commit details."
    } else {
        Write-Warning "Not a git repository."
    }
}

Set-Alias git-info Show-GitInformation

Function Start-GitGraphicalInterface {
    & "$(Find-GraphicalGit)"
}

Set-Alias gitk Start-GitGraphicalInterface


Function Update-AllGitRepositories {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd,
        [switch] $Pull
    )

    Write-Output "Updating from remote repository for GIT projects in this directory..."

    $folders = Get-ChildItem -Path $Path | Where-Object { $_.PSIsContainer }

    foreach ($folder in $folders) {
        if (Test-Path "$(Join-Path $folder.FullName ".git")") {
            Write-Output "== $($folder.Name)"
            Push-Location $folder.FullName
            & "$(Find-Git)" remote -v
            & "$(Find-Git)" fetch --all --recurse-submodules
            if ($Pull) {
                if ($(& "$(Find-Git)" remote)) {
                    Write-Output "Pulling changes into currently checked out branch..."
                    & "$(Find-Git)" pull
                }
            }
            Pop-Location
            Write-Output ""
        }
    }
}
