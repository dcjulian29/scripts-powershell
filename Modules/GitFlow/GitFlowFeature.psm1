function Pop-GitFlowFeature {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the feature')"
  )

  & "$(Find-Git)" flow feature pull $Name
}

Set-Alias Pull-GitFlowFeature Pop-GitFlowFeature

function Publish-GitFlowFeature {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the feature')"
  )

 & "$(Find-Git)" flow feature publish $Name
}

function Remove-GitFlowFeature {
  & "$(Find-Git)" fetch
  & "$(Find-Git)" flow feature delete --remote
  & "$(Find-Git)" checkout develop
  & "$(Find-Git)" pull
}

Set-Alias Abort-GitFlowFeature Remove-GitFlowFeature

function Start-GitFlowFeature {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the feature')"
  )

 & "$(Find-Git)"  flow feature start $Name
}

Set-Alias gffs Start-GitFlowFeature

function Stop-GitFlowFeature {
  & "$(Find-Git)"  flow feature finish
}

Set-Alias gfff Stop-GitFlowFeature
Set-Alias Finish-GitFlowFeature Stop-GitFlowFeature

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
