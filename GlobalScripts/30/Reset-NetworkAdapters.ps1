function Reset-NetworkAdapters {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -ne 'Disconnected' }

    foreach ($adapter in $adapters) {
        Write-Output "Restarting $($adapter.Name) interface..."
        $adapter | Restart-NetAdapter

        Start-Sleep 2

        $adapter | Set-DnsClientServerAddress -ResetServerAddresses
    }
}
