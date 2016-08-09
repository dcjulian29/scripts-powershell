$script:GIT_INSTALL_ROOT = Find-ProgramFiles "Git\bin"
$script:GIT = "${script:GIT_INSTALL_ROOT}\git.exe"

Function Start-GitHubFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')",
        [flag] $Force
    )

    $branch = Invoke-Expression "& `"$GIT`" rev-parse --abbrev-ref HEAD"
    
    if ((-not ($branch -in @( "master", "develop", "dev" ))) -and (-not $force)) {
        Write-Error "You are not in one of these branches: master, develop, dev. Use -Force to create a new feature from this branch if that is what you want."
    } else {
        & "$GIT" checkout -b $Name
    }
}

Function Publish-GitHubFlowFeature {
    param (
        [string] $Name
    )

   & "$GIT" push $Name
}

Function Pull-GitHubFlowFeature {
    param (
        [string] $Name = "$(Read-Host 'What is the name of the feature')"
    )

   & "$GIT" fetch 
   & "$GIT" checkout $Name
}

###################################################################################################

Export-ModuleMember Start-GitHubFlowFeature
Export-ModuleMember Publish-GitHubFlowFeature
Export-ModuleMember Pull-GitHubFlowFeature

Set-Alias ghffs Start-GitHubFlowFeature
Export-ModuleMember -Alias ghffs
