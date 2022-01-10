function Get-AdoRepository {
    param (
        [Alias("Name")]
        [string] $Id
    )

    if ($Id) {
        Invoke-AzureDevOpsApi "git/repositories/$Id"
    } else {
        (Invoke-AzureDevOpsApi "git/repositories").value
    }
}
