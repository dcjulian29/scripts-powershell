$script:vsPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\IDE\devenv.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe')

Function Find-VisualStudioSolutions {
    param(
        [string]
        $LookingFor
    )

    $files = Get-ChildItem -Filter "*.sln" | % { $_.Name }

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

Function Start-VisualStudio {
    param (
        
        [string]$Project,
        [int]$Version,
        [switch]$AsAdmin
    )

    if (-not $Version) {
        $vs = $script:vsPath
    } else {
        switch ($Version) {
            2017 { $vsv = "15.0" }
            2015 { $vsv = "14.0" }
            2013 { $vsv = "12.0" }
        }

        if ($Version -eq 2017) {
            $vs = (Find-ProgramFiles "Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe")
        } else {
            $vs = (Find-ProgramFiles "Microsoft Visual Studio $vsv\Common7\IDE\devenv.exe")
        }
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

Function Start-VisualStudio2017 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2017 -AsAdmin $AsAdmin
}

Function Start-VisualStudio2015 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2015 -AsAdmin $AsAdmin
}

Function Start-VisualStudio2013 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2013 -AsAdmin $AsAdmin
}

Function Start-VisualStudioCode {
    $code = (Find-ProgramFiles "Microsoft VS Code\Code.exe")

    & $code $args
}

###################################################################################################

Export-ModuleMember Start-VisualStudio
Export-ModuleMember Start-VisualStudio2013
Export-ModuleMember Start-VisualStudio2015
Export-ModuleMember Start-VisualStudio2017
Export-ModuleMember Find-VisualStudioSolutions
Export-ModuleMember Start-VisualStudioCode

Set-Alias vs2013 Start-VisualStudio2013
Export-ModuleMember -Alias vs2013

Set-Alias vs2015 Start-VisualStudio2015
Export-ModuleMember -Alias vs2015

Set-Alias vs2017 Start-VisualStudio2017
Export-ModuleMember -Alias vs2017

Set-Alias vs-solutions Find-VisualStudioSolutions
Export-ModuleMember -Alias vs-solutions

Set-Alias code Start-VisualStudioCode
Export-ModuleMember -Alias code
