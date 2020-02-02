function Start-GitHubFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

    $branch = Get-GitRepositoryBranch

    if (-not ($branch -eq "master")) {
        Write-Error "You are not in the master branch. Use -Force to create a new feature from this branch if that is what you want."
    } else {
        if (-not ($name.StartsWith("feature/"))) {
            $Name = "feature/$Name"
        }

        & "$(Find-Git)" checkout -b $Name
    }
}

Set-Alias ghffs Start-GitHubFlowFeature

function Stop-GitHubFlowFeature {

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

    $branch = Get-GitRepositoryBranch

    if ($branch -eq $Name) {
        & "$(Find-Git)" pull
    } else {
        & "$(Find-Git)" fetch
        & "$(Find-Git)" checkout $Name
    }
}

Set-Alias -Name Pull-GitHubFlowFeature -Value Pop-GitHubFlowFeature

function Publish-GitHubFlowFeature {
    param (
        [string] $Name
    )

   & "$(Find-Git)" push $Name
    if (-not ($name.StartsWith("feature/"))) {
        $Name = "feature/$Name"
    }
}
