@{
    ModuleVersion = '2019.12.25.1'
    GUID = '099256ed-ac18-4e56-8017-bb9d9077fb74'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Git.psm1'
    NestedModules = @(
        "GitBackups.psm1"
        "GitBranches.psm1"
        "GitCommits.psm1"
        "GitEnvironments.psm1"
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
        "Get-GitIgnoreTemplate"
        "Get-GitLastCommit"
        "Get-GitLastTag"
        "Get-GitRepositoryBranch"
        "Get-GitRepositoryStatus"
        "Invoke-FetchGitRepository"
        "Invoke-PullGitRepository"
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
        "Restore-GitRepositoryBackup"
        "Show-AllGitInformation"
        "Show-GitInformation"
        "Start-GitGraphicalInterface"
        "Update-AllGitRepositories"
        "Update-GitRepository"
    )
    AliasesToExport = @(
        "Fetch-GitRepository"
        "gb"
        "gbr"
        "gfetch"
        "gitk"
        "git-gc-all"
        "git-info"
        "gpull"
        "gpush"
        "gpushall"
        "gs"
        "gup"
        "Pull-GitRepository"
        "status-all-projects"
    )
}
