@{
    ModuleVersion = '2106.3.1'
    GUID = 'f5af3a59-c5ad-4e26-8502-c14c3ee8d5df'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Kubernetes.psm1'
    NestedModules = @(
        "k3s.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-KubeControl"
        "Get-K3SCluster"
        "Install-K3D"
        "Invoke-KubeControl"
        "New-K3S"
        "Open-K3SDashboard"
        "Remove-K3S"
        "Start-K3S"
        "Start-K3SDashboard"
        "Stop-K3S"
        "Test-K3D"
        "Use-K3S"
        "Use-K8SContext"
    )
    AliasesToExport = @(
        "Find-KubeCTL"
        "Invoke-KubeCTL"
        "k"
        "k3s-start"
        "k3s-stop"
        "k3s-remove"
        "kubectl"
    )
}
