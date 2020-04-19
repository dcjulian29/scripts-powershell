function Find-VisualStudio {
    First-Path `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe')
}

function Find-VisualStudioSolutions {
    param(
        [string]
        $LookingFor
    )

    $files = Get-ChildItem -Filter "*.sln" | ForEach-Object { $_.Name }

    $number = 0
    if ($LookingFor) {
        foreach ($file in $files) {
            $number++

            if ($number -eq $LookingFor) {
                Write-Output $file
            }
        }
    } else {
        foreach ($file in $files) {
            $number++

            Write-Output $("{0,2}: $($file)" -f $number)
        }
    }

    if ($number -eq 0) {
        Write-Error "No Visual Studio solution files found."
    }
}

Set-Alias vs-solutions Find-VisualStudioSolutions

function Find-VSIX {
    First-Path `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\IDE\VSIXInstaller.exe')
}

function Find-VSVars {
    First-Path `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat')
}

function Get-VSVars {
    if ($global:VSVariables) {
        return $global:VSVariables
    }

    $vsvar = Find-VSVars
    $environment = @{}

    if ($vsvar) {
        $cmd = "`"$vsvar`" >nul & set"

        cmd /c $cmd | ForEach-Object {
            $p, $v = $_.Split('=')
            if (-not ($p.StartsWith('_'))) {
                if (-not (Test-Path "env:$p")) {
                    $environment.$p = $v
                }
            }
        }
    }

    $global:VSVariables = $environment

    return $global:VSVariables
}

function Set-VSVars {
    $enviornment = Get-VSVars

    $enviornment.Keys | ForEach-Object {
        Set-Item -Path "env:$_" -Value $enviornment[$_]
    }
}

function Start-VisualStudio {
    param (
        [string]$Project,
        [int]$Version,
        [bool]$AsAdmin
    )

    if (-not $Version) {
        $vs = Find-VisualStudio
    } else {
        switch ($Version) {
            2019 { $vsv = "2019" }
            2017 { $vsv = "2017" }
        }

        $vs = First-Path `
            (Find-ProgramFiles "Microsoft Visual Studio\$vsv\Enterprise\Common7\IDE\devenv.exe") `
            (Find-ProgramFiles "Microsoft Visual Studio\$vsv\Professional\Common7\IDE\devenv.exe") `
            (Find-ProgramFiles "Microsoft Visual Studio\$vsv\Community\Common7\IDE\devenv.exe") `
            (Find-ProgramFiles "Microsoft Visual Studio $vsv\Common7\IDE\devenv.exe")
    }

    if (Test-Path $vs) {
        if ($Project -match "\d+") {
            $solution = $(Find-VisualStudioSolutions $Project)
        } else {
            if ($Project -match "^.+\.sln$") {
                $solution = $Project
            } else {
                $solution = "$project.sln"
            }
        }

        if ($solution) {
            if (Test-Path $solution) {
                if ($AsAdmin) {
                    Start-Process -FilePath $vs -ArgumentList $solution -Verb RunAs
                } else {
                    Start-Process -FilePath $vs -ArgumentList $solution
                }
            } else {
                Write-Error "$solution does not exists!"
            }
        } else {
            Write-Error "The solution does not exists!"
        }
    } else {
        Write-Error "Visual Studio $Version is not installed on this computer"
    }
}

function Start-VisualStudio2017 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2017 -AsAdmin $AsAdmin.IsPresent
}

Set-Alias vs2017 Start-VisualStudio2017

function Start-VisualStudio2019 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2019 -AsAdmin $AsAdmin.IsPresent
}

Set-Alias vs2019 Start-VisualStudio2019
function Start-VisualStudioCode {
    $code = (Find-ProgramFiles "Microsoft VS Code\Code.exe")

    if ([String]::IsNullOrWhiteSpace($args)) {
        Start-Process -FilePath $code -RedirectStandardOutput "NUL"
    } else {
        Start-Process -FilePath $code -ArgumentList $args -RedirectStandardOutput "NUL"
    }
}

Set-Alias code Start-VisualStudioCode

Set-Alias vscode Start-VisualStudioCode

function Update-CodeSnippets {
    $snippets = First-Path `
    "$env:USERPROFILE\Documents\Visual Studio 2019\Code Snippets" `
    "$env:USERPROFILE\Documents\Visual Studio 2017\Code Snippets"

    if (Test-Path $snippets) {
        Copy-Item -Path $snippets -Destination "$env:SystemDrive\etc\visualstudio" -Recurse -Force
    }
}
