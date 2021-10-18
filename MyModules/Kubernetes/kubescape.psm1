$script:BASE_DIR= "${env:USERPROFILE}/.kubescape"

function getKubescapeConfig {
    Invoke-WebRequest "https://api.github.com/repos/armosec/kubescape/releases/latest" | ConvertFrom-Json
}

function getKubescapeRelease {
    return $(getKubescape).tag_name
}

function getKubescapeReleaseUrl {
    return $(getKubescape).html_url.Replace("/tag/","/download/") + "/kubescape-windows-latest"
}

##############################################################################

function Install-Kubescape {
    if (Test-Kubescape) {
        Write-Warning "Kubescape is already installed."
    } else {
        Invoke-WebRequest -Uri "$(getKubescapeReleaseUrl)" -OutFile "${script:BASE_DIR}/kubescape.exe"
    }
}

function Invoke-Kubescape {
    & "${script:BASE_DIR}/kubescape.exe" $args
}

Set-Alias -Name kubescape -Value Invoke-Kubescape

function Scan-Kubescape {
    & "${script:BASE_DIR}/kubescape.exe" scan framework nsa ./*
}

function Test-Kubescape {
    return $(Test-Path "${script:BASE_DIR}/kubescape.exe")
}
