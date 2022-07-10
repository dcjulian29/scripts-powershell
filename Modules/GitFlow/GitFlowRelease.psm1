function Pop-GitFlowRelease {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the release')"
  )

  & "$(Find-Git)" flow release pull $Name
}

Set-Alias Pull-GitFlowRelease Pop-GitFlowRelease

function Publish-GitFlowRelease {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the release')"
  )

 & "$(Find-Git)" flow release publish $Name
}

function Remove-GitFlowRelease {
  & "$(Find-Git)" fetch
  & "$(Find-Git)" flow release delete --remote
  & "$(Find-Git)" checkout develop
  & "$(Find-Git)" pull
}

Set-Alias Abort-GitFlowRelease Remove-GitFlowRelease

function Start-GitFlowRelease {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the release')"
  )

 & "$(Find-Git)"  flow release start $Name
}

Set-Alias gfrs Start-GitFlowRelease

function Stop-GitFlowRelease {
  & "$(Find-Git)"  flow release finish -m "Release"
}

Set-Alias gfrf Stop-GitFlowRelease
Set-Alias Finish-GitFlowRelease Stop-GitFlowRelease
