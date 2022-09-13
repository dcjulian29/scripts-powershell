@{
    ModuleVersion = '2209.13.1'
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
        "Invoke-FetchGitRepository"
        "Invoke-GitAdd"
        "Invoke-GitLog"
        "Invoke-GraphicGit"
        "Invoke-GraphicGitHistory"
        "Invoke-PullGitRepository"
        "Merge-GitRepository"
        "Optimize-AllGitRepositories"
        "Publish-GitRepositoryToPROD"
        "Publish-GitRepositoryToQA"
        "Publish-GitRepositoryToUAT"
        "Push-GitRepositoriesThatAreTracked"
        "Push-GitRepository"
        "Remove-AllGitChanges"
        "Remove-GitChanges"
        "Remove-GitRepositoryBackup"
        "Remove-LastGitCommit"
        "Rename-GitBranch"
        "Restore-GitRepositoryBackup"
        "Set-GitConfigValue"
        "Show-AllGitInformation"
        "Show-AllGitRepositoryStatus"
        "Show-GitInformation"
        "Start-GitGraphicalInterface"
        "Test-GitCommit"
        "Test-GitRepository"
        "Test-GitRepositoryDirty"
        "Update-AllGitRepositories"
        "Update-GitRepository"
    )
    AliasesToExport = @(
        "Fetch-GitRepository"
        "ga"
        "gb"
        "gbr"
        "gfetch"
        "gitg"
        "gitk"
        "git-gc-all"
        "git-info"
        "gl"
        "gpull"
        "gpush"
        "gpushall"
        "gs"
        "gup"
        "has_git_commit"
        "is_git_repo"
        "Pull-GitRepository"
        "status-all-projects"
    )
    PrivateData = @{
      PSData = @{
        Tags = @(
          "dcjulian29"
          "Credentials"
          "Web"
        )
        LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
        ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
        RequireLicenseAcceptance = $false
        ExternalModuleDependencies = @()
      }
    }
    HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/Git'
}
