function Get-AzureDevOpsRepository {
    [CmdletBinding(DefaultParameterSetName='searchByName')]
    param (
        [Parameter(ParameterSetName='searchByName')]
        [Alias("Name")]
        [string] $RepositoryName,
        [Parameter(ParameterSetName='searchById')]
        [Alias("Id")]
        [string] $RepositoryId
    )

    $repositories = (Invoke-AzureDevOpsApi "git/repositories").value

    if ($RepositoryName) {
        $repositories = $repositories | Where-Object { $_.name -eq $RepositoryName}
    }

    if ($RepositoryId) {
        $repositories = $repositories | Where-Object { $_.id -eq $RepositoryId}
    }

    return $repositories
}

function Get-AzureDevOpsGitCommit {
    [CmdletBinding(DefaultParameterSetName='searchByName')]
    param (
        [Parameter(Mandatory=$true, ParameterSetName='searchByName')]
        [string] $Name,
        [Parameter(Mandatory=$true, ParameterSetName='searchByCommitId')]
        [Parameter(Mandatory=$true, ParameterSetName='searchByRepositoryId')]
        [string] $RepositoryId,
        [Parameter(Mandatory=$true, ParameterSetName='searchByCommitId')]
        [Alias("Id")]
        [string] $CommitId
    )

    if ($PSCmdlet.ParameterSetName -eq 'searchByName') {
        $repositories = Get-AzureDevOpsRepository -Name $Name

        if ($repositories.Count -gt 1) {
            Write-Warning "Found multiple repositories by that name, taking the first one..."
            $RepositoryId = $repositories[0].id
        } else {
            $RepositoryId = $repositories.id
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'searchByCommitId') {
        $commit = Invoke-AzureDevOpsApi "git/repositories/$RepositoryId/commits/$CommitId"

        return $commit
    }

    # FutureUpdate: Add parameters to gather filters and then prepare filters querystring
    $filter = ""


    $commitsRaw = (Invoke-AzureDevOpsApi "git/repositories/$id/commits" -Filter $filter).value
    $commits = @()

    foreach ($commit in $commitsRaw) {
        $detail = New-Object PSObject

        $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $commit.commitId
        $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $commit.committer.name
        $detail | Add-Member -Type NoteProperty -Name 'Email' -Value $commit.committer.email
        $detail | Add-Member -Type NoteProperty -Name 'Date' -Value $commit.committer.date
        $detail | Add-Member -Type NoteProperty -Name 'Message' -Value $commit.comment

        if ($PSCmdlet.ParameterSetName -ne 'searchByRepositoryId') {
            $detail | Add-Member -Type NoteProperty -Name 'Repository' -Value $RepositoryId
        }

        $Commits += $detail
    }

    return $commits
}
