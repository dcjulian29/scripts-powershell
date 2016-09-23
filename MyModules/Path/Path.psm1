Function Get-64Bit {
    if ([System.IntPtr]::Size -ne 4) {
        $true
    } else {
        $false
    }
}

Function Add-CygwinPath {
    $path = Find-CygwinPath
        
    if ($path.Length -gt 0)
    {
        $env:Path = "$path;$($env:PATH)"    
    }
    else
    {
        Write-Error "Cygwin Not Found!"
    }
}

Function Add-JavaPath {
    $path = Find-JavaPath
        
    if ($path.Length -gt 0)
    {
        $env:JAVA_HOME = $path
        $env:Path = "$path\bin;$($env:PATH)"    
    }
    else
    {
        Write-Error "Java Runtime Not Found!"
    }
}

Function Add-MongoDbPath {
    $path = Find-MongoDbPath
        
    if ($path.Length -gt 0)
    {
        $env:Path = "$path;$($env:PATH)"    
    }
    else
    {
        Write-Error "MongoDb Not Found!"
    }
}

Function Add-NodeJsPath {
    $path = Find-NodeJsPath
        
    if ($path.Length -gt 0)
    {
        $env:Path = "$path;$($env:PATH)"    
    }
    else
    {
        Write-Error "NodeJS Not Found!"
    }
}

Function Find-CygwinPath {
    $cygwin = ""
    
    if (Test-Path "C:\cygwin\bin")
    {
        $cygwin = "C:\cygwin\bin" 
    }
    
    $cygwin
}

Function Find-JavaPath {
    if (Get-64Bit) {
        $path = Join-Path ${env:ProgramFiles(x86)} "Java"
        $path64 = Join-Path $env:ProgramFiles "Java"
    } else {
        $path = Join-Path $env:ProgramFiles "Java"
        $path64 = Join-Path $env:ProgramFiles "Java"
    }

    $java = ""

    if (Test-Path $path) {
        $path  = (Get-ChildItem -Path $path -Recurse -Include "bin").FullName `
            | Sort-Object | Select-Object -Last 1
        if (Test-Path $path) {
            $java = $path
        }
    }
    
    if (Test-Path $path64) {
        $path64  = (Get-ChildItem -Path $path64 -Recurse -Include "bin").FullName `
            | Sort-Object | Select-Object -Last 1
        if (Test-Path $path64) {
            $java = $path64
        }
    }

    $java
}

Function Find-MongoDbPath {
    $mongo = ""
    
    if (Test-Path "C:\Program Files\MongoDB\bin")
    {
        $mongo = "C:\Program Files\MongoDB\bin" 
    }

    if (Test-Path "C:\tools\apps\mongodb")
    {
        $mongo = "C:\tools\apps\mongodb"
    }
    
    $mongodb
}

Function Find-NodeJsPath {
    $nodejs = ""
    
    if (Test-Path "C:\Program Files\nodejs")
    {
        $nodejs = "C:\Program Files\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm" 
    }

    if (Test-Path "C:\Program Files (x86)\nodejs")
    {
        $nodejs = "C:\Program Files (x86)\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm" 
    }
    
    $nodejs
}

###############################################################################

Export-ModuleMember Add-CygwinPath
Export-ModuleMember Add-JavaPath
Export-ModuleMember Add-MongoDbPath
Export-ModuleMember Add-NodeJsPath
Export-ModuleMember Find-CygwinPath
Export-ModuleMember Find-JavaPath
Export-ModuleMember Find-MongoDbPath
Export-ModuleMember Find-NodeJsPath

Set-Alias path-cygwin Add-CygwinPath
Set-Alias path-java Add-JavaPath
Set-Alias path-mongodb Add-MongoDbPath
Set-Alias path-nodejs Add-NodeJsPath

Export-ModuleMember -Alias path-cygwin
Export-ModuleMember -Alias path-java
Export-ModuleMember -Alias path-mongodb
Export-ModuleMember -Alias path-nodejs
