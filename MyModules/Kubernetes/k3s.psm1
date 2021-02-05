function Get-K3SCluster {
    param (
        [string] $ClusterName
    )

    $cluster = k3d cluster list --output json | ConvertFrom-Json

    if ($ClusterName) {
        $cluster = $cluster | Where-Object { $_.name -eq $ClusterName }
    }

    return $cluster
}

function Install-K3D {
    if (Test-K3D) {
        Write-Warning "K3D is already installed."
    } else {
        choco install --version=4.0.0 -y k3d
    }
}

function Open-K3SDashboard {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    Start-Process `
        "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

    kubectl proxy --accept-hosts='^localhost$,^127\.0\.0\.1$,^\[::1\]$' `
        --context="k3d-$ClusterName"
}

function Remove-K3S {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    k3d cluster delete $ClusterName
}

Set-Alias -Name k3s-remove -Value Remove-K3S

function Start-K3S {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    if (-not (Test-K3D)) {
        Install-K3D
    }

    if (Get-K3SCluster $ClusterName) {
        k3d cluster start $ClusterName
    } else {
        k3d cluster create $ClusterName
    }

    ($node = kubectl get nodes --context="k3d-$ClusterName") 1> $null 2> $null

    while (-not ($node)) {
        ($node = kubectl get nodes --context="k3d-$ClusterName") 1> $null 2> $null

        Start-Sleep -Seconds 1
    }

    $ready = $false
    while (-not ($ready)) {
        ($node = kubectl get nodes --context="k3d-$ClusterName" --no-headers) 1> $null 2> $null
        if ($node -like "* Ready *") {
            $ready = $true
        }

        Start-Sleep -Seconds 1
    }

    Write-Output "`n==== Cluster"
    kubectl cluster-info --context="k3d-$ClusterName"
    Write-Output "`n==== Nodes"
    kubectl get nodes --context="k3d-$ClusterName"
    Write-Output "`n==== Pods"
    kubectl get pods --all-namespaces --context="k3d-$ClusterName"
    Write-Output "`n==== Services"
    kubectl get services --all-namespaces --context="k3d-$ClusterName"
    Write-Output "`n==== Deployments"
    kubectl get deployments --all-namespaces --context="k3d-$ClusterName"
}

Set-Alias -Name k3s-start -Value Start-K3S

function Start-K3SDashboard {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    kubectl apply `
        -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml `
        --context="k3d-$ClusterName"

    if (Test-Path "$env:TEMP\$ClusterName-Dashboard.yml") {
        Remove-Item -Path "$env:TEMP\$ClusterName-Dashboard.yml" -Force
    }

    Set-Content -Path "$env:TEMP\$ClusterName-Dashboard.yml" -Value @"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
"@

    kubectl apply -f "$env:TEMP\$ClusterName-Dashboard.yml" --context="k3d-$ClusterName"

    Remove-Item -Path "$env:TEMP\$ClusterName-Dashboard.yml" -Force

    $token = $(kubectl -n kubernetes-dashboard get secret `
        $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") `
        -o go-template="{{.data.token | base64decode}}" `
        --context="k3d-$ClusterName")

    Write-Output "To access the dashboard on the '$ClusterName' cluster, use the following token:"
    Write-Output "`n$token"
}

function Stop-K3S {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    k3d cluster stop $ClusterName
}

Set-Alias -Name k3s-stop -Value Stop-MongoDBServer

function Test-K3D {
    return ($null -ne (choco list -lo | Where-object { $_.ToLower().StartsWith("k3d") }))
}

function Use-K3S {
    param (
        [string] $ClusterName = $env:COMPUTERNAME
    )

    kubectl config use-context "k3d-$ClusterName"
}
