function Use-K8SContext {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Context
    )

    kubectl config use-context "$Context"
}
