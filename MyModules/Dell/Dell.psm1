Function Invoke-IdracJnlp {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    if (-not $(Assert-Elevation)) { return }

    $java = "C:\Program Files\Java"

    $latest = (Get-ChildItem -Path $java | `
        Where-Object { $_.PsIsContainer } | `
        Sort-Object Name -Descending | `
        Select-Object -First 1).Name

    $java_home = Join-Path -Path $java -ChildPath $latest

    $security = "$java_home\lib\security\java.security"

    $config = Get-Content $security `
        | ForEach-Object { $_ -replace 'jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024', `
            '#jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024' }

    Set-Content -Path $security -Value $config
    
    if (-not $(Assert-Elevation)) { return }

    Start-Process "$java_home/bin/javaws.exe" -ArgumentList $path

    Start-Sleep -Seconds 2

    $config = Get-Content $security `
        | ForEach-Object { $_ -replace '#jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024', `
            'jdk.jar.disabledAlgorithms=MD2, MD5, RSA keySize < 1024' }
}