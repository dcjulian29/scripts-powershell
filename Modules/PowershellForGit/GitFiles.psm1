function removeNonExistFiles {
    param (
        [string[]] $files
    )

    $returnedFiles = @()

    foreach ($file in $files) {
        if (Test-Path $file) {
            $returnedFiles +=  $file
        }
    }

    return $returnedFiles
}

function getFileList {
    param (
        [string] $CommitId,
        [string] $StartCommitId# = "HEAD~1"
    )

    return $(cmd /c """$(Find-Git)"" diff --name-only $CommitId $StartCommitId")
}

###############################################################################

function Get-GitFilesFromCommit {
    param (
        [Parameter(Mandatory=$true)]
        [string] $CommitId
    )

    return (cmd /c """$(Find-Git)"" log -m -1 --name-only --first-parent --pretty="""" $CommitId")
}

function Get-GitFilesFromLastCommit {
    return removeNonExistFiles `
        (getFileList -CommitId "HEAD" -StartCommitId "HEAD~1")
}

function Get-GitFilesSinceLastTag {
    return removeNonExistFiles `
        (getFileList -CommitId "HEAD" `
            -StartCommitId (Get-LastGitTag))
}

function Get-GitFilesSinceTag {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Tag
    )

    return removeNonExistFiles `
        (getFileList -CommitId (cmd /c """$(Find-Git)"" show-ref --tags --hash $Tag"))
}
