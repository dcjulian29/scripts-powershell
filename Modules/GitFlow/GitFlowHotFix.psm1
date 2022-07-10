function Pop-GitFlowHotfix {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
  )

  & "$(Find-Git)"  flow hotfix pull $Name
}

Set-Alias Pull-GitFlowHotfix Pop-GitFlowHotfix

function Publish-GitFlowHotfix {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
  )

 & "$(Find-Git)"  flow hotfix publish $Name
}

function Remove-GitFlowHotfix {
  & "$(Find-Git)" fetch
  & "$(Find-Git)" flow hotfix delete --remote
  & "$(Find-Git)" checkout develop
  & "$(Find-Git)" pull
}

Set-Alias Abort-GitFlowHotfix Remove-GitFlowHotfix

function Start-GitFlowHotfix {
  param (
      [string] $Name = "$(Read-Host 'What is the name of the hotfix')"
  )

 & "$(Find-Git)"  flow hotfix start $Name
}

Set-Alias gfhs Start-GitFlowHotfix

function Stop-GitFlowHotfix {
  & "$(Find-Git)"  flow hotfix finish -m "Hotfix"
}

Set-Alias gfhf Stop-GitFlowHotfix
Set-Alias Finish-GitFlowHotfix Stop-GitFlowHotfix
