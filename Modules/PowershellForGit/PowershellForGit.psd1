@{
  ModuleVersion = '2301.31.1'
  GUID = '099256ed-ac18-4e56-8017-bb9d9077fb74'
  Author = 'Julian Easterling'
  PowerShellVersion = '3.0'
  RootModule = 'PowershellForGit.psm1'
  NestedModules = @(
    "GitBackups.psm1"
    "GitBranches.psm1"
    "GitCommits.psm1"
    "GitConfig.psm1"
    "GitEnvironments.psm1"
    "GitFiles.psm1"
    "GitFlow.psm1"
    "GitFlowFeature.psm1"
    "GitFlowHotFix.psm1"
    "GitFlowRelease.psm1"
    "GitHubFlow.psm1"
    "GitIgnores.psm1"
  )
  TypesToProcess = @()
  FormatsToProcess = @()
  FunctionsToExport = @(
    "Add-GitIgnoreTemplate"
    "Add-GitIgnoreToLocalRepository"
    "Add-GitIgnoreToRemoteRepository"
    "Backup-GitRepository"
    "Find-Git"
    "Find-GraphicGit"
    "Find-GraphicGitHistory"
    "Find-NonMergedBranches"
    "Get-GitConfigValue"
    "Get-GitFilesFromCommit"
    "Get-GitFilesFromLastCommit"
    "Get-GitFilesSinceLastTag"
    "Get-GitFilesSinceTag"
    "Get-GitIgnoreTemplate"
    "Get-GitPrimaryBranch"
    "Get-GitRepositoryBranch"
    "Get-GitRepositoryStatus"
    "Get-GitRootDirectory"
    "Get-LastGitCommit"
    "Get-LastGitTag"
    "Initialize-GitFlow"
    "Invoke-FetchGitRepository"
    "Invoke-GitAdd"
    "Invoke-GitLog"
    "Invoke-GraphicGit"
    "Invoke-GraphicGitHistory"
    "Invoke-PullGitRepository"
    "Merge-GitRepository"
    "Optimize-AllGitRepositories"
    "Pop-GitFlowFeature"
    "Pop-GitFlowHotfix"
    "Pop-GitFlowRelease"
    "Pop-GitHubFlowFeature"
    "Publish-GitFlowFeature"
    "Publish-GitFlowHotfix"
    "Publish-GitFlowRelease"
    "Publish-GitHubFlowFeature"
    "Publish-GitRepositoryToPROD"
    "Publish-GitRepositoryToQA"
    "Publish-GitRepositoryToUAT"
    "Push-GitRepositoriesThatAreTracked"
    "Push-GitRepository"
    "Remove-AllGitChanges"
    "Remove-GitChanges"
    "Remove-GitFlowFeature"
    "Remove-GitFlowHotfix"
    "Remove-GitFlowRelease"
    "Remove-GitRepositoryBackup"
    "Remove-LastGitCommit"
    "Rename-GitBranch"
    "Restore-GitRepositoryBackup"
    "Set-GitConfigValue"
    "Show-AllGitInformation"
    "Show-AllGitRepositoryStatus"
    "Show-GitInformation"
    "Start-GitFlowFeature"
    "Start-GitFlowHotfix"
    "Start-GitFlowRelease"
    "Start-GitGraphicalInterface"
    "Start-GitHubFlowFeature"
    "Stop-GitFlowFeature"
    "Stop-GitFlowHotfix"
    "Stop-GitFlowRelease"
    "Stop-GitHubFlowFeature"
    "Test-GitCommit"
    "Test-GitRepository"
    "Test-GitRepositoryDirty"
    "Update-AllGitRepositories"
    "Update-GitFlowFeature"
    "Update-GitHubFlowFeature"
    "Update-GitRepository"
  )
  AliasesToExport = @(
    "Abort-GitFlowFeature"
    "Abort-GitFlowHotfix"
    "Abort-GitFlowRelease"
    "Fetch-GitRepository"
    "Finish-GitFlowFeature"
    "Finish-GitFlowHotfix"
    "Finish-GitFlowRelease"
    "Finish-GitHubFlowFeature"
    "ga"
    "gb"
    "gbr"
    "gfetch"
    "gfff"
    "gffs"
    "gfhf"
    "gfhs"
    "gfrf"
    "gfrs"
    "ghfff"
    "ghffs"
    "ghffu"
    "gitg"
    "git-gc-all"
    "git-info"
    "gitk"
    "gpull"
    "gpush"
    "gpushall"
    "gs"
    "gup"
    "has_git_commit"
    "is_git_repo"
    "Pull-GitFlowFeature"
    "Pull-GitFlowHotfix"
    "Pull-GitFlowRelease"
    "Pull-GitHubFlowFeature"
    "Pull-GitRepository"
    "status-all-projects"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "Git"
        "GitHubFlow"
        "GitFlow"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/Git'
}
