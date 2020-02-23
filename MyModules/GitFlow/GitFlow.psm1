function Initialize-GitFlow {
   & "$(Find-Git)" flow init -d
}

function Pop-GitFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

    & "$(Find-Git)"  flow feature pull $Name
}

function Pop-GitFlowHotfix {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
    )

    & "$(Find-Git)"  flow hotfix pull $Name
}

function Publish-GitFlowFeature {
    param (
        [string] $Name
    )

   & "$(Find-Git)"  flow feature publish $Name
}

function Publish-GitFlowHotfix {
    param (
        [string] $Name
    )

   & "$(Find-Git)"  flow hotfix publish $Name
}

function Remove-GitFlowFeature {
   & "$(Find-Git)" fetch
   & "$(Find-Git)" flow feature delete --remote
   & "$(Find-Git)" checkout develop
   & "$(Find-Git)" pull
}

function Remove-GitFlowRelease {
   & "$(Find-Git)" fetch
   & "$(Find-Git)" flow release delete --remote
   & "$(Find-Git)" checkout develop
   & "$(Find-Git)" pull
}

function Start-GitFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

   & "$(Find-Git)"  flow feature start $Name
}

function Start-GitFlowHotfix {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
    )

   & "$(Find-Git)"  flow hotfix start $Name
}

function Start-GitFlowRelease {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the release')"
    )

   & "$(Find-Git)"  flow release start $Name
}

function Stop-GitFlowFeature {
   & "$(Find-Git)"  flow feature finish
}

function Stop-GitFlowHotfix {
   & "$(Find-Git)"  flow hotfix finish -m "Hotfix"
}

function Stop-GitFlowRelease {
   & "$(Find-Git)"  flow release finish -m "Release"
}

function Update-GitFlowFeature {
    $branch = $(Get-GitRepositoryBranch).ToLowerInvariant()

    if (-not $branch.StartsWith("feature/")) {
        Write-Error "You are not in a GitFlow Feature branch."
    } else {
        Write-Output "Making Sure that local branches or up-to-date..."
        & "$(Find-Git)"  checkout develop
        & "$(Find-Git)"  pull origin
        & "$(Find-Git)"  checkout $branch
        & "$(Find-Git)"  pull origin
        & "$(Find-Git)"  merge develop --no-ff
    }
}

###################################################################################################

Set-Alias Abort-GitFlowFeature Remove-GitFlowFeature
Set-Alias Abort-GitFlowRelease Remove-GitFlowRelease
Set-Alias Finish-GitFlowFeature Stop-GitFlowFeature
Set-Alias Finish-GitFlowRelease Stop-GitFlowRelease
Set-Alias gfff Stop-GitFlowFeature
Set-Alias gffs Start-GitFlowFeature
Set-Alias gfhf Stop-GitFlowHotfix
Set-Alias gfhs Start-GitFlowHotfix
Set-Alias gfrf Stop-GitFlowRelease
Set-Alias gfrs Start-GitFlowRelease
Set-Alias Pull-GitFlowFeature Pop-GitFlowFeature
Set-Alias Pull-GitFlowHotfix Pop-GitFlowHotfix
