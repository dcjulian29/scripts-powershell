function Find-KubeControl {
    First-Path `
        "${env:ALLUSERSPROFILE}\chocolatey\lib\kubernetes-cli\tools\kubernetes\client\bin\kubectl.exe" `
        (Find-ProgramFiles "Docker\Docker\Resources\bin\kubectl.exe")
}

Set-Alias -Name Find-KubeCTL -Value Find-KubeControl

function Invoke-KubeControl {
    $kubectl = Find-KubeControl

    if ($kubectl) {
        if (Test-KubeControl) {
            cmd /c """$kubectl"" $args"
        } else {
            throw "Kubernetes Control is not installed on this system."
        }
    }
}

Set-Alias -Name Invoke-KubeControl -Value Invoke-KubeControl
Set-Alias -Name k -Value Invoke-KubeControl

function Test-KubeControl {
    $kubectl = Find-KubeControl

    if ($kubectl) {
        if (Test-Path $kubectl) {
            return $true
        } else {
            return $false
        }
    }
}

function Use-K8SContext {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Context
    )

    kubectl config use-context "$Context"
}
