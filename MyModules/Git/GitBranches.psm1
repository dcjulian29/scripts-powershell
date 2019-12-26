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
