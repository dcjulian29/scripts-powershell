﻿function Find-VisualStudio {
    First-Path `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe') `
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
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Professional\Common7\IDE\VSIXInstaller.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Community\Common7\IDE\VSIXInstaller.exe') `
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
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Enterprise\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat')
}

Set-Alias Find-VisualStudioVariables Find-VSVars

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

function Install-VsixByName {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$PackageName
  )

  $baseProtocol = "https:"
  $baseHostName = "marketplace.visualstudio.com"

  $uri = "$baseProtocol//$baseHostName/items?itemName=$PackageName"
  $file = "${env:TEMP}\$([Guid]::NewGuid()).vsix"
  $html = Invoke-WebRequest -Uri $uri -UseBasicParsing -SessionVariable session
  $anchor = $html.Links |
    Where-Object { $_.class -eq 'install-button-container' } |
    Select-Object -ExpandProperty href

  if (-not $anchor) {
    throw "Could not determine download URL on the Visual Studio Extensions page."
  }

  $href = "$($baseProtocol)//$($baseHostName)$($anchor)"

  Write-Output "-  VSIX Url: $href"

  Invoke-WebRequest $href -OutFile $file -WebSession $session

  if (Test-Path $file) {
    Install-VsixPackage -Package $PackageName -Path $file
  }
}

function Install-VsixPackage {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path,
        [string]$Package = $((Resolve-Path $Path | Get-Item).BaseName)
    )

    $vsix = Find-VSIX
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0} ]" -f [RegEx]::Escape($invalidChars)
    $date = Get-Date -Format "yyyyMMdd_HHmmss"

    $logFile = "$(Get-LogFolder)\{1}-vsix-{0}.log" -f ($Package -replace $re), $date
    $vsixFile = (Resolve-Path $Path | Get-Item).FullName

    Write-Output "- VSIX File: $vsixFile"
    Write-Output "-  Log File: $logFile"

    try {
        $arguments = @(
            "/quiet"
            "/logFile:$logFile"
            "$vsixFile"
        )

        $run = Start-Process -FilePath $vsix -ArgumentList $arguments -PassThru -Wait -NoNewWindow
        $exitCode = [Int32]$run.ExitCode

        switch ($exitCode) {
          1001 {
            Write-Output "INFORMATION: The '$Package' Extension is already installed."
          }

          #1002 extensionmanager.notinstalledexception
          #1003 extensionmanager.notpendingdeletionexception
          #1005 extensionmanager.identifierconflictexception
          #1006 extensionmanager.missingtargetframeworkexception
          #1007 extensionmanager.missingreferencesexception
          #1008 extensionmanager.breaksexistingextensionsexception
          #1009 extensionmanager.installbymsiexception
          #1010 extensionmanager.systemcomponentexception
          #1011 extensionmanager.missingpackagepartexception
          #1012 extensionmanager.invalidextensionmanifestexception
          #1013 extensionmanager.invalidextensionpackageexception
          #1014 extensionmanager.nestedextensioninstallexception
          #1015 extensionmanager.requiresadminrightsexception
          #1016 extensionmanager.proxycredentialsrequiredexception
          #1017 extensionmanager.invalidpermachineoperationexception
          #1018 extensionmanager.referenceconstraintexception
          #1019 extensionmanager.dependencyexception
          #1020 extensionmanager.inconsistentnestedreferenceidexception
          #1021 extensionmanager.unsupportedproductexception
          #1022 extensionmanager.directoryexistsexception
          #1023 extensionmanager.filesinuseexception
          #1024 extensionmanager.cannotuninstallorphanedcomponentsexception
          #2001 vsixinstaller.invalidcommandlineexception
          #2002 vsixinstaller.invalidlicenseexception

          2003 {
            Write-Output "Warning: The '$Package' Extension isn't compatible with installed SKUs."
          }

          #2004 vsixinstaller.blockingprocessesexception
          #3001 means other exception.
          Default { if ($exitCode -gt 0) { throw } }
        }
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Output " "
        Write-Output "An error occurred during installation of the $($Package.BaseName) Extension..."
        Write-Output "Error: $errorMessage ($exitCode)"
        if (Test-Path $logFile) {
          Write-Output "Review the log file: $logFile"
          Get-Content -Path $logFile
        }
    }
}

function Set-VSVars {
    $enviornment = Get-VSVars

    $enviornment.Keys | ForEach-Object {
        Set-Item -Path "env:$_" -Value $enviornment[$_]
    }
}

Set-Alias Register-VisualStudioVariables Set-VsVars
Set-Alias Register-VSVariables Set-VsVars
Set-Alias vsvars32 Set-VsVars
Set-Alias VSVariables Set-VsVars

function Show-VisualStudioInstalledVersions {
  $installed = @()

  @(2017, 2019, 2022) | ForEach-Object {
    $vs = $null
    $vs = First-Path `
        (Find-ProgramFiles "Microsoft Visual Studio\$_\Enterprise\Common7\IDE\devenv.exe") `
        (Find-ProgramFiles "Microsoft Visual Studio\$_\Professional\Common7\IDE\devenv.exe") `
        (Find-ProgramFiles "Microsoft Visual Studio\$_\Community\Common7\IDE\devenv.exe") `
        (Find-ProgramFiles "Microsoft Visual Studio $_\Common7\IDE\devenv.exe")

    if ($vs) {
      $installed += $_
    }
  }

  if ((Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\IDE\devenv.exe')) {
    $installed += 2015
  }

  if ((Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe')) {
    $installed += 2013
  }

  if ((Find-ProgramFiles 'Microsoft Visual Studio 1q.0\Common7\IDE\devenv.exe')) {
    $installed += 2012
  }

  return $installed
}

function Show-VsixExtensions {
  $file = "${env:TEMP}\$([Guid]::NewGuid()).log"
  $arguments = @(
      "/quiet"
      "/logFile:$file"
      "/appIdName:VS"
      "/uninstall:nosuchxt"
  )

  Start-Process -FilePath $(Find-VSIX) -ArgumentList $arguments -Wait -NoNewWindow

  $contents = Get-Content $file | Select-String " - Found '"

  $extensions = @()

  foreach ($item in $contents) {
    $item = $item.ToString()
    $item = $item.Substring($item.IndexOf('''') + 1)
    $item = $item.Substring(0, $item.LastIndexOf(''''))

    $xml = [xml](Get-Content $item)

    $extension = [PSCustomObject]@{
      Id = $xml.PackageManifest.Metadata.Identity.Id
      Version = $xml.PackageManifest.Metadata.Identity.Version
      File = $item
    }

    if (($extension.Id).Length -eq 0) {
      $extension.Id = (Resolve-Path $item | Get-Item).BaseName
    }

    if ($extension.Id.Length -gt 0) {
      $extensions += $extension
    }

    $extension = $null
  }

  return $extensions
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
            2022 { $vsv = "2022" }
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


function Start-VisualStudio2019 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2019 -AsAdmin $AsAdmin.IsPresent
}

Set-Alias vs2019 Start-VisualStudio2019

function Start-VisualStudio2022 {
    param (
        [string]$Project,
        [switch]$AsAdmin
    )

    Start-VisualStudio $Project 2022 -AsAdmin $AsAdmin.IsPresent
}

Set-Alias vs2022 Start-VisualStudio2022

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

function Test-VisualStudioInstalledVersion {
  param (
    [int] $Version
  )

  $installed = Show-VisualStudioInstalledVersions

  if ($installed.GetType().Name -eq 'Int32') {
    return $installed -eq $Version
  } else {
    return $installed.Contains($Version)
  }
}

function Update-CodeSnippets {
    $snippets = First-Path `
    "$env:USERPROFILE\Documents\Visual Studio 2019\Code Snippets" `
    "$env:USERPROFILE\Documents\Visual Studio 2017\Code Snippets"

    if (Test-Path $snippets) {
        Copy-Item -Path $snippets -Destination "$env:SystemDrive\etc\visualstudio" -Recurse -Force
    }
}