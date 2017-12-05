Function Clear-KubernetesProfile {
    $env:KUBECONFIG = ''
}

Function Load-KubernetesProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the Kubernetes Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/kubernetes" -ChildPath "$ProfileName.yml"

    if (-not (Test-Path $profileFile)) {
        Write-Error "Kubernetes Profile does not exist!"
    } else {
        $env:KUBECONFIG = $ProfileFile
    }
}

###################################################################################################

Export-ModuleMember Clear-KubernetesProfile
Export-ModuleMember Load-KubernetesProfile

Set-Alias kubernetes-profile-clear Clear-KubernetesProfile
Export-ModuleMember -Alias kubernetes-profile-clear

Set-Alias kubernetes-profile-load Load-KubernetesProfile
Export-ModuleMember -Alias kubernetes-profile-load
