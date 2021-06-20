function Start-GitHubFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')",
        [switch] $Force
    )

    if (-not ($Force -or ($(Get-GitRepositoryBranch) -eq $(Get-GitPrimaryBranch)))) {
        Write-Error "You are not in the $(Get-GitPrimaryBranch) branch. Use -Force to create a new feature from this branch if that is what you want."
    } else {
        if (-not ($name.StartsWith("feature/"))) {
            $Name = "feature/$Name"
        }

        & "$(Find-Git)" checkout -b $Name
    }
}

Set-Alias ghffs Start-GitHubFlowFeature

function Stop-GitHubFlowFeature {
    $branch = Get-GitRepositoryBranch

    if (-not ($branch.StartsWith("feature/"))) {
        Write-Error "You are not in a feature branch."
    } else {
        $remote = & "$(Find-Git)" ls-remote --heads origin $branch

        if ($remote) {
            & "$(Find-Git)" pull
        }

        & "$(Find-Git)" checkout $(Get-GitPrimaryBranch)
        & "$(Find-Git)" merge --no-ff $branch
        & "$(Find-Git)" branch --delete $branch

        if ($remote) {
            & "$(Find-Git)" push origin --delete $branch
        }
    }
}

Set-Alias -Name Finish-GitHubFlowFeature -Value Stop-GitHubFlowFeature
Set-Alias -Name ghfff -Value Stop-GitHubFlowFeature

function Pop-GitHubFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

    if (-not ($name.StartsWith("feature/"))) {
        $Name = "feature/$Name"
    }

    $remote = & "$(Find-Git)" ls-remote --heads origin $Name

    if (-not $remote) {
        Write-Error "The feature does not exist on the remote repository."
    } else {
        $branch = Get-GitRepositoryBranch

        if ($branch -eq $Name) {
            & "$(Find-Git)" pull
        } else {
            & "$(Find-Git)" fetch
            & "$(Find-Git)" checkout $Name
        }
    }
}

Set-Alias -Name Pull-GitHubFlowFeature -Value Pop-GitHubFlowFeature

function Publish-GitHubFlowFeature {
    param (
        [string] $Name = $(Get-GitRepositoryBranch)
    )

    if (-not ($name.StartsWith("feature/"))) {
        $Name = "feature/$Name"
    }

    $remote = & "$(Find-Git)" ls-remote --heads origin $Name

    if ($remote) {
        & "$(Find-Git)" push -u origin $Name
    } else {
        & "$(Find-Git)" push --set-upstream origin $Name
    }
}

function Update-GitHubFlowFeature {
    param (
        [switch]$Push
    )

    $branch = $(Get-GitRepositoryBranch).ToLowerInvariant()

    if (-not $branch.StartsWith("feature/")) {
        Write-Error "You are not in a feature branch."
    } else {
        & "$(Find-Git)" checkout $(Get-GitPrimaryBranch)
        & "$(Find-Git)" pull origin
        & "$(Find-Git)" checkout $branch

        $remote = & "$(Find-Git)" ls-remote --heads origin $Name

        if ($remote) {
            & "$(Find-Git)" pull origin
        }

        & "$(Find-Git)" merge $(Get-GitPrimaryBranch) --no-ff

        if ($Push) {
            if ($remote) {
                & "$(Find-Git)" push -u origin $Name
            } else {
                & "$(Find-Git)" push --set-upstream origin $Name
            }
        }
    }
}

Set-Alias -Name ghffu -Value Update-GitHubFlowFeature
