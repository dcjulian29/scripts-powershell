function Reset-NetworkAdapters {
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

    foreach ($adapter in $adapters) {
        Restart-Adapter $adapter

        Start-Sleep 2

        $adapter | Set-DnsClientServerAddress -ResetServerAddresses
    }
}
