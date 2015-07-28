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
