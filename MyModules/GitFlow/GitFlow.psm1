$script:GIT_INSTALL_ROOT = Find-ProgramFiles "Git\bin"
$script:GIT = "${script:GIT_INSTALL_ROOT}\git.exe"

Function Initialize-GitFlow {
   & "$GIT" flow init -d
}

Function Start-GitFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

   & "$GIT" flow feature start $Name
}

Function Finish-GitFlowFeature {
   & "$GIT" flow feature finish
}

Function Publish-GitFlowFeature {
    param (
        [string] $Name
    )

   & "$GIT" flow feature publish $Name
}

Function Pull-GitFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

   & "$GIT" flow feature pull $Name
}

Function Update-GitFlowFeature {
    $branch = Invoke-Expression "& `"$GIT`" rev-parse --abbrev-ref HEAD"
    $branchNormalized = $branch.ToLowerInvariant()
    
    if (-not $branchNormalized.StartsWith("feature/")) {
        Write-Error "You are not in a GitFlow Feature branch."
    } else {
        Write-Output "Making Sure that local branches or up-to-date..."
        & "$GIT" checkout develop
        & "$GIT" pull origin
        & "$GIT" checkout $branch
        & "$GIT" pull origin
        & "$GIT" merge develop --no-ff
    }
}

Function Start-GitFlowRelease {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the release')"
    )

   & "$GIT" flow release start $Name
}

Function Finish-GitFlowRelease {
   & "$GIT" flow release finish -m "Release"
}

Function Start-GitFlowHotfix {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
    )

   & "$GIT" flow hotfix start $Name
}

Function Finish-GitFlowHotfix {
   & "$GIT" flow hotfix finish
}

###################################################################################################

Export-ModuleMember Initialize-GitFlow
Export-ModuleMember Start-GitFlowFeature
Export-ModuleMember Finish-GitFlowFeature
Export-ModuleMember Publish-GitFlowFeature
Export-ModuleMember Pull-GitFlowFeature
Export-ModuleMember Update-GitFlowFeature
Export-ModuleMember Start-GitFlowRelease
Export-ModuleMember Finish-GitFlowRelease
Export-ModuleMember Start-GitFlowHotfix
Export-ModuleMember Finish-GitFlowHotfix


Set-Alias gffs Start-GitFlowFeature
Export-ModuleMember -Alias gffs

Set-Alias gfff Finish-GitFlowFeature
Export-ModuleMember -Alias gffs

Set-Alias gfrs Start-GitFlowRelease
Export-ModuleMember -Alias gffs

Set-Alias gfrf Finish-GitFlowRelease
Export-ModuleMember -Alias gffs
