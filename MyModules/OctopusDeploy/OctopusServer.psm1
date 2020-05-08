function Get-OctopusServerUptime {
    $info = Invoke-OctopusApi "serverstatus/system-info"

    if ($info) {
        return $info.Uptime
    }
}

function Get-OctopusServerVersion {
    $info = Invoke-OctopusApi "serverstatus/system-info"

    if ($info) {
        return $info.Version
    }
}
