function Get-GitLastCommit {
    [CmdletBinding(DefaultParameterSetName="Id")]
    param (
        [Parameter(ParameterSetName="Id")]
        [Switch]$Id,
        [Parameter(ParameterSetName="Author")]
        [Switch]$Author,
        [Parameter(ParameterSetName="Author")]
        [Switch]$Email,
        [Parameter(ParameterSetName="Date")]
        [Switch]$Date,
        [Parameter(ParameterSetName="DateTime")]
        [Switch]$DateTime
    )

    $parameters = "--no-pager log --max-count=1"

    if ($DateTime) {
        $parameters += " --pretty=format:""%aD"""

        Get-Date $(cmd /c """$(Find-Git)"" $parameters")
    } else {
        if ($Id) {
            $parameters = "rev-parse $(Get-GitRepositoryBranch)"
        }

        if ($Author) {
            $parameters += " --pretty=format:""%an"""
        }

        if ($Email) {
            $parameters += " --pretty=format:""%ae"""
        }

        if ($Author -and $Email) {
            $parameters += " --pretty=format:""%an <%ae>"""
        }

        if ($Date) {
            $parameters += " --pretty=format:""%ad"""
        }

        cmd /c """$(Find-Git)"" $parameters"
    }
}

function Remove-AllGitChanges {
    & "$(Find-Git)" reset HEAD
    & "$(Find-Git)" stash save --keep-index
    & "$(Find-Git)" stash drop
}

function Remove-GitChanges {
    param (
        [ValidateNotNullorEmpty()]
        [ValidateScript({Test-Path $_})]
        [string] $File
    )

    & "$(Find-Git)" checkout $File
}

function Remove-LastGitCommit {
    if ($(& "$(Find-Git)" diff --exit-code) -and $(& "$(Find-Git)" diff --cached --exit-code)) {
        & "$(Find-Git)" reset --soft HEAD~1
    } else {
        Write-Warning "Commit is already pushed... You will need to revert the changes instead."
    }
}
