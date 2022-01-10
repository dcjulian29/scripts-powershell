function Publish-GitRepositoryToPROD {
    [CmdletBinding(DefaultParameterSetName="QA")]
    param (
        [Parameter(ParameterSetName="UAT")]
        [switch] $FromUAT,
        [Parameter(ParameterSetName="QA")]
        [switch] $FromQA
    )

    if ( -not ($FromUAT -or $FromQA)) {
        throw "You must select an environment to publish from."
    }

    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    & "$(Find-Git)" checkout prod

    if ($FromQA) {
        $commit = "Publish QA to Production on $date"
        & "$(Find-Git)" merge --no-ff qa -m $commit
    } else {
        $commit = "Publish UAT to Production on $date"
        & "$(Find-Git)" merge --no-ff uat -m $commit
    }
}

function Publish-GitRepositoryToQA {

    $tag = & $(Find-Git) lasttag
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish $tag to QA on $date"

    & "$(Find-Git)" checkout qa

    & "$(Find-Git)" merge --no-ff master -m $commit
}

function Publish-GitRepositoryToUAT {
    $date = [DateTime]::Now.ToString("MMMM d, yyyy ""at"" h:mm ""GMT""zzz")

    $commit = "Publish QA to UAT on $date"

    & "$(Find-Git)" checkout uat

    & "$(Find-Git)" merge --no-ff qa -m $commit
}
