function Get-GitPrimaryBranch {
  (& "$(Find-Git)" remote show origin | Select-String "HEAD branch: ").ToString().Replace('HEAD branch:', '').Trim()
}

function Find-Git {
  First-Path `
    ((Get-Command git -ErrorAction SilentlyContinue).Source) `
    ("${env:ProgramFiles}\Git\bin\git.exe")
}

function Find-GraphicalGit {
  First-Path `
    ((Get-Command git-gui -ErrorAction SilentlyContinue).Source) `
    ("${env:ProgramFiles}\Git\cmd\git-gui.exe")
}

function Find-GraphicalGitHistory {
  First-Path `
    ((Get-Command gitk -ErrorAction SilentlyContinue).Source) `
    ("${env:ProgramFiles}\Git\cmd\gitk.exe")
}

function Get-GitRootDirectory {
  param(
    [string] $Path = $PWD.Path
  )

  if (Test-GitRepository -Path $Path) {
    $root = & "$(Find-Git)" -C $Path rev-parse --show-toplevel

    if ($root.Length -gt 0) {
      if (Test-Path -Path $root -PathType Container) {
        return Get-Item $root
      }
    }
  }

  return $null
}

function Get-GitRepositoryStatus {
    & "$(Find-Git)" status
}

Set-Alias gs Get-GitRepositoryStatus

function Invoke-FetchGitRepository {
    & "$(Find-Git)" fetch --progress --prune --all
}

Set-Alias Fetch-GitRepository Invoke-FetchGitRepository
Set-Alias gfetch Invoke-FetchGitRepository

function Invoke-GitAdd {
  & "$(Find-Git)" add $("$args")
}

Set-Alias -Name "ga" -Value "Invoke-GitAdd"

function Invoke-GitLog {
  & "$(Find-Git)" log $("$args")
}

function Invoke-GraphicalGit {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd
    )

    Push-Location $Path
    & "$(Find-GraphicalGit)" citool
    Pop-Location
}

Set-Alias -Name gitg -Value Invoke-GraphicalGit

function Invoke-GraphicalGitHistory {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string] $Path = $pwd
    )

    Push-Location $Path
    & "$(Find-GraphicalGitHistory)"
    Pop-Location
}

Set-Alias -Name gitk -Value Invoke-GraphicalGitHistory

function Invoke-PullGitRepository {
    Fetch-GitRepository
    & "$(Find-Git)" pull
}

Set-Alias Pull-GitRepository Invoke-PullGitRepository
Set-Alias gpull Invoke-PullGitRepository

function Optimize-AllGitRepositories {
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

function Push-GitRepositoriesThatAreTracked {
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

function Push-GitRepository {
    $remote = & "$(Find-Git)" remote
    "Pushing to $remote..."
    & "$(Find-Git)" push
    "Pushing tags..."
    & "$(Find-Git)" push --tags
}

Set-Alias gpush Push-GitRepository

function Show-AllGitInformation {
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

function Show-AllGitRepositoryStatus {
    param(
        $Folders = $((Get-ChildItem -Directory "$(Get-DefaultCodeFolder)").FullName)
    )

    $repos = @()

    foreach ($folder in $Folders) {
        Push-Location $folder
        if (Test-GitRepository) {
            $status = Test-GitRepositoryDirty

            $repos += [PSCustomObject]@{
                Folder = $folder
                Dirty = $status
            }
        }

        Pop-Location
    }

    return $repos
}

function Show-GitInformation {
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

function Start-GitGraphicalInterface {
    & "$(Find-GraphicalGit)"
}

Set-Alias gitk Start-GitGraphicalInterface

function Test-GitCommit {
  param (
    [string] $Path = $PWD.Path
  )

  & "$(Find-Git)" -C $Path rev-parse --short HEAD 2>&1 | Out-Null

  if ($LASTEXITCODE -gt 0) {
    return $false
  }

  return $true
}

Set-Alias -Name "has_git_commit" -Value "Test-GitCommit"

function Test-GitRepository {
    param (
        [string] $Path = $PWD.Path
    )


    & "$(Find-Git)" -C $Path rev-parse 2>&1 | Out-Null

    if ($LASTEXITCODE -gt 0) {
        return $false
    }

    return $true
}

Set-Alias -Name "is_git_repo" -Value Test-GitRepository

function Test-GitRepositoryDirty {
    param (
        [string] $Path = $PWD.Path
    )

    if ($null -ne (& "$(Find-Git)" -C "$Path" diff --stat)) {
        return $true
    } else {
        return $false
    }
}

function Test-GitRepositoryRoot {
  param (
      [string] $Path = $PWD.Path
  )

  return ($Path -eq (Get-GitRootDirectory).FullName)
}

function Update-AllGitRepositories {
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

function Update-GitRepository {
    [CmdletBinding(DefaultParameterSetName="Update")]
    param (
        [Parameter(ParameterSetName="Update", Position = 0)]
        [Parameter(ParameterSetName="Reset", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Repository")]
        [string]$Path = $pwd,
        [Parameter(ParameterSetName="Update")]
        [Parameter(ParameterSetName="Reset")]
        [string[]]$Branches,
        [Parameter(ParameterSetName="Reset")]
        [Switch]$Reset,
        [Parameter(Mandatory=$true,ParameterSetName="Reset")]
        [string]$Url
    )

    $directory = (Get-Item (Resolve-Path $Path))
    $repository = $directory.BaseName

    if ($pwd.Path -ne $directory.FullName) {
        Push-Location $directory.FullName
        $startedOutside = $true
    }

    Write-Output " "
    Write-Output "===================================================> $repository"

    if ($Reset) {
        Pop-Location ..

        if (Test-Path $repository) {
            Write-Output "Resetting $repository in '$($directory.FullName)'..."

            Backup-GitRepository -Path $repository

            Remove-Item -Path $repository -Recurse -Force
        }

        & "$(Find-Git)" clone "$Url/$repository" "$repository"
        if (-not (Test-Path $Repository)) {
            Write-Error "There was an error cloning the reposiory!"

            return
        }
    }

    $orignalBranch = $(Get-GitRepositoryBranch)

    if ($Branches.Length -eq 0) {
        $Branches = @($orignalBranch)
    }

    Write-Output "    Original Branch: $orignalBranch"

    foreach ($branch in $Branches) {
        Write-Output "--> $branch"
        & "$(Find-Git)" checkout $branch
        Write-Output " "
        & "$(Find-Git)" pull
        Write-Output " "
    }

    $currentBranch = $(Get-GitRepositoryBranch)

    if ($currentBranch -ne $orignalBranch) {
        & "$(Find-Git)" checkout $orignalBranch
    }

    if ($startedOutside) {
        Pop-Location
    }
}

Set-Alias gup Update-GitRepository
