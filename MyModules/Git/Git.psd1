@{
    ModuleVersion = '2019.12.21.1'
    GUID = '099256ed-ac18-4e56-8017-bb9d9077fb74'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Git.psm1'
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
        "Pull-GitRepository"
        "status-all-projects"
    )
}
