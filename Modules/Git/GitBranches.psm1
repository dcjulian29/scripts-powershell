function Get-GitRepositoryBranch {
    [CmdletBinding(DefaultParameterSetName="Local")]
    param (
        [Parameter(ParameterSetName="Local")]
        [switch]$Local,
        [Parameter(ParameterSetName="Remote")]
        [switch]$Remote,
        [Parameter(ParameterSetName="Upstream")]
        [switch]$Upstream
    )

    $parameters = "symbolic-ref --short HEAD" # Current Branch

    if ($Local) {
        $parameters = "for-each-ref --sort refname --format=%(refname:short) refs/heads"
    }

    if ($Remote) {
        $parameters = "for-each-ref --sort refname --format=%(refname:short) refs/remotes"
    }

    if ($Upstream) {
        $parameters = "rev-parse --symbolic-full-name $(Get-GitBranch)@{u}"
    }

    cmd /c """$(Find-Git)"" $parameters"
}

function Find-NonMergedBranches {
    param (
        [string] $Path = $PWD.Path
    )

    if (-not (Test-GitRepository $Path)) {
        throw "This is not a Git repository."
    }

    Push-Location $Path

    $branches = git branch -r --no-merged

    $commits = @()
    $list = @()

    foreach ($branch in $branches) {
        $branch = $branch.Trim()
        $commits += git log -n 1 --format="%ci|%cr|%an|%ae|$branch" --no-merges --first-parent $branch
    }

    foreach ($commit in $commits) {
            $line = $commit.Split('|')
            $detail = New-Object PSObject

            $detail | Add-Member -Type NoteProperty -Name 'Branch' -Value $line[4]
            $detail | Add-Member -Type NoteProperty -Name 'Age' -Value $line[1]
            $detail | Add-Member -Type NoteProperty -Name 'LastCommitDate' -Value $line[0]
            $detail | Add-Member -Type NoteProperty -Name 'AuthorName' -Value $line[2]
            $detail | Add-Member -Type NoteProperty -Name 'AuthorEmail' -Value $line[3]

            $list += $detail
    }

    Pop-Location

    return $list
}

function Merge-GitRepository {
    param (
        [Alias("Repository")]
        [string]$Path = $pwd,
        [Parameter(Mandatory=$true)]
        [string]$SourceBranch,
        [Parameter(Mandatory=$true)]
        [string]$DestinationBranch,
        [switch]$Push
    )

    Update-GitRepository -Repository $Path -Branches @($SourceBranch, $DestinationBranch)

    $directory = (Get-Item (Resolve-Path $Path))

    if ($pwd.Path -ne $directory.FullName) {
        Push-Location $directory.FullName
        $startedOutside = $true
    }

    $current = Get-GitRepositoryBranch

    if ($current -ne $DestinationBranch) {
        & "$(Find-Git)" checkout $DestinationBranch
    }

    Write-Output "Merging $SourceBranch to $DestinationBranch..."
    & "$(Find-Git)" --no-optional-locks merge --no-ff $SourceBranch

    if ($Push) {
        Write-Output "Pushing merge (if any) to origin..."
        & "$(Find-Git)" --no-optional-locks push -v origin ${DestinationBranch}:$DestinationBranch
    }

    if ($current -ne $DestinationBranch) {
        & "$(Find-Git)" checkout $current
    }

    if ($startedOutside) {
        Pop-Location
    }
}

function Rename-GitBranch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [switch]$NoPush
    )

    if (Test-GitRepository) {
        $oldName = Get-GitRepositoryBranch

        & "$(Find-Git)" branch -m $Name

        if ($NoPush) {
            return
        }

        $remotes = & "$(Find-Git)" remote -v | Select-String '(\S+)\s+\S+\s+\(push\)$' -AllMatches
        $upstream = Get-GitRepositoryBranch -Upstream

        for ($i = 0; $i -lt $remotes.Matches.Count; $i++) {
            $remote = $remotes[$i].Matches.Groups[1].Value
            if ($upstream -like "*$remote*") {
                & "$(Find-Git)" push $remote -u $Name
                & "$(Find-Git)" push $remote --delete $oldName
            }
        }
    }
}
