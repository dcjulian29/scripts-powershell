Function updateunzip($url, $filename, $repo, $destinationPath)
{
    (New-Object System.Net.WebClient).DownloadFile("$url/$filename", "$env:TEMP\$filename")
    $shell = New-Object -com Shell.Application
    $shell.namespace($env:TEMP).CopyHere($shell.namespace("$env:TEMP\$filename").items(), 0x10) 
    Copy-Item -Path "$env:TEMP\$repo\*" -Destination $destinationPath -Recurse -Force
    Remove-Item -Path "$env:TEMP\$repo" -Recurse -Force
    Remove-Item -Path "$env:TEMP\$filename" -Force
}


Function Update-ScriptsFromGitHub {
    updateunzip "https://github.com/dcjulian29/bin-scripts/archive" "master.zip" "bin-scripts-master" $env:SYSTEMDRIVE\tools\binaries
    updateunzip "https://github.com/dcjulian29/dev-scripts/archive" "master.zip" "dev-scripts-master" $env:SYSTEMDRIVE\tools\development
    updateunzip "https://github.com/dcjulian29/WindowsPowerShell/archive" "master.zip" "WindowsPowerShell-master" $env:SYSTEMDRIVE\tools\powershell
}