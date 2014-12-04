Function updateunzip($repo, $destinationPath)
{
    $baseUrl = "https://github.com/dcjulian29/scripts-{0}/archive/master.zip"
    $url = $baseUrl.Replace("{0}", $repo)
    $master = "$env:TEMP\master.zip"
    
    if (Test-Path $master) {
        Remove-Item $master -Force
    }
    
    (New-Object System.Net.WebClient).DownloadFile("$url", $master)

    $shell = New-Object -com Shell.Application
    $shell.namespace($env:TEMP).CopyHere($shell.namespace($master).items(), 0x10) 

    Copy-Item -Path "$env:TEMP\scripts-$repo-master\*" -Destination $destinationPath -Recurse -Force

    Remove-Item -Path "$env:TEMP\scripts-$repo-master" -Recurse -Force
    Remove-Item -Path $master -Force
}


Function Update-ScriptsFromGitHub {
    if (Test-Path $env:SYSTEMDRIVE\tools\binaries) {
        updateunzip "binaries" $env:SYSTEMDRIVE\tools\binaries
    }
    
    if (Test-Path $env:SYSTEMDRIVE\tools\development) {
        updateunzip "development" $env:SYSTEMDRIVE\tools\development
    }

    if (Test-Path $env:SYSTEMDRIVE\tools\powershell) {
        updateunzip "powershell" $env:SYSTEMDRIVE\tools\powershell
    }
}