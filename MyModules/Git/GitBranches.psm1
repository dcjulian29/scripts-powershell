function Get-GitRepositoryBranch {
    [CmdletBinding(DefaultParameterSetName="Local")]
    param (
        [Parameter(ParameterSetName="Local")]
        [switch]$Local,
        [Parameter(ParameterSetName="Remote")]
        [switch]$Remote,
        [Parameter(ParameterSetName="Upstream")]
        [switch]$Upstream
    )

    $parameters = "symbolic-ref --short HEAD" # Current Branch

    if ($Local) {
        $parameters = "for-each-ref --sort refname --format=%(refname:short) refs/heads"
    }

    if ($Remote) {
        $parameters = "for-each-ref --sort refname --format=%(refname:short) refs/remotes"
    }

    if ($Upstream) {
        $parameters = "rev-parse --symbolic-full-name $(Get-GitBranch)@{u}"
    }

    cmd /c """$(Find-Git)"" $parameters"
}

function Merge-GitRepository {
    param (
        [string]$Path = $pwd,
        [string]$SourceBranch,
        [string]$DestinationBranch,
        [switch]$Push
    )

    if ($pwd -ne $Path) {
        Push-Location $Path
        $startedOutside = $true
    }

    Update-GitRepository -Repository $Path -Branches @($SourceBranch, $DestinationBranch)

    $current = Get-GitRepositoryBranch

    if ($current -ne $DestinationBranch) {
        & "$(Find-Git)" checkout $DestinationBranch
    }

    Write-Output "Merging $SourceBranch to $DestinationBranch..."
    & "$(Find-Git)" --no-optional-locks merge --no-ff $SourceBranch

    if ($Push) {
        Write-Output "Pushing merge (if any) to origin..."
        & "$(Find-Git)" --no-optional-locks push -v --tags origin ${DestinationBranch}:$DestinationBranch
    }

    if ($current -ne $DestinationBranch) {
        & "$(Find-Git)" checkout $current
    }

    if ($startedOutside) {
        Pop-Location
    }
}
