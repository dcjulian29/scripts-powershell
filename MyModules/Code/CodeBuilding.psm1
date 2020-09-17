function Get-CakeBuildBootstrapper {
    if (Test-Path build.ps1) {
        Remove-Item -Confirm -Path build.ps1
    }

    if (Test-Path build.ps1) {
        throw "Cake.Build Bootstraper File Still Exists! Can't Continue..."
    }

    Invoke-WebRequest https://cakebuild.net/download/bootstrapper/windows -OutFile build.ps1
}

function Get-CodeCoverageReport {
    if (-not (Test-Path build.cake)) {
        Write-Warning "This project doesn't support Cake.Build so cannot generate Code Coverage."
        return
    }

    Invoke-BuildProject "-Target Compile -Configuration Debug"

    if (-not (Test-Path "tools")) {
        return
    }

    $openCover = (Get-ChildItem -Filter "OpenCover.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "\tools\OpenCover.Console.exe"

    $reportGenerator = (Get-ChildItem -Filter "ReportGenerator.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "\tools\net47\ReportGenerator.exe"

    $xunit = (Get-ChildItem -Filter "xunit.runner.console.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "\tools\net472\xunit.console.exe"


    if (-not ($openCover -and $reportGenerator -and $xunit)) {
        Write-Warning "Code Coverage tools not found."
        return
    }

    if (Test-Path ".coverage") {
        Remove-Item ".coverage" -Recurse -Force
    }

    New-Item -ItemType Directory -Path ".coverage" | Out-Null

    if (Test-Path "build") {
        $buildDirectory = "$((Get-Location).Path)\build"
    }

    if (Test-Path ".build") {
        $buildDirectory = "$((Get-Location).Path)\.build"
    }

    $cmd = "$openCover --% " `
        + "-target:""$xunit"" " `
        + "-targetargs:""\""$buildDirectory\output\UnitTests.dll\"" -stoponfail -parallel all -noshadow"" " `
        + "-register:user " `
        + "-output:.coverage\coverage.xml " `
        + "-filter:""+[*]* -[UnitTests]* -[xunit.*]*"" " `
        + "-excludebyattribute:System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverageAttribute " `
        + "-excludebyfile:""*Designer.csb*\\*.g.csb*.*.g.i.cs"""

    Invoke-Expression -Command $cmd

    $cmd = "$reportGenerator --% " `
        + "-reports:""$((Get-Location).Path)\.coverage\coverage.xml"" " `
        + "-targetdir:""$((Get-Location).Path)\.coverage"""

    Invoke-Expression -Command $cmd

    Start-Process "$((Get-Location).Path)\.coverage\index.htm"
}

function Get-MsBuildErrorsFromLog {
    param(
        [string]$Path
    )

    $errors = @()
    $lines = Get-Content $Path | select-string ": error "

    foreach ($line in $lines) {
        $line = $line.ToString()

        if ($line -like '*error MSB*') {
            continue
        }

        $filename = $line.Split(':')[0]

        if ($filename -like '*>*') {
            $filename = $filename.Split('>')[1]
        }

        if ($filename -like '*(*') {
            $filename = $filename.Split('(')[0]
        }

        $filename = $filename.Trim()

        $code = $line.Split(':')[1].Replace("error ", "").Trim()
        $desc = $line.Split('[')[0].Split(':')[2].Trim()

        $detail = New-Object PSObject

        $detail | Add-Member -Type NoteProperty -Name 'File' -Value $filename
        $detail | Add-Member -Type NoteProperty -Name 'Code' -Value $code
        $detail | Add-Member -Type NoteProperty -Name 'Error' -Value $desc

        $errors += $detail
    }

    $errors
}

function Edit-StyleCopSettings {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path
    )

    & $(Find-StyleCopSettingsEditor) $Path
}

function Find-MSBuild {
    return First-Path `
        (Find-ProgramFiles '\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
        (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe') `
        (Find-ProgramFiles 'MSBuild\15.0\bin\MSBuild.exe') `
        (Find-ProgramFiles 'MSBuild\14.0\bin\MSBuild.exe')
}

function Find-StyleCopSettingsEditor {
    (Get-ChildItem -Path "${env:USERPROFILE}\.nuget\packages\stylecop.msbuild" -Recurse `
        | Where-Object { $_.Name -match "StyleCop.SettingsEditor.exe" } `
        | Sort-Object FullName -Descending `
        | Select-Object -First 1).FullName
}

function Invoke-BuildProject {
    $param = "$args"
    if (Test-Path build.cake) {
        $tee = "| Tee-Object ${env:TEMP}\cake_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        if (-not ($param.StartsWith('-'))) {
            if ($param) {
                # Assume a target was passed in
                Invoke-Expression ".\build.ps1 -target $param $tee"
            } else {
                Invoke-Expression ".\build.ps1 $tee"
            }
        } else {
            Invoke-Expression ".\build.ps1 $param $tee"
        }
    } elseif (Test-Path build.ps1) {
        Invoke-Psake .\build.ps1 $param
    } elseif (Test-Path build.bat) {
        .\build.bat $param
    } elseif (Test-Path build.cmd) {
        .\build.cmd $param
    } elseif (Test-Path build.xml) {
        C:\tools\apps\nant\bin\nant.exe -buildfile:build.xml $param
    } else {
        Write-Host "This directory does not include build script to build the project"
    }
}

Set-Alias bp Invoke-BuildProject

function Invoke-MSBuild {
    Register-VisualStudioVariables
    if (Test-Path $(Find-MSBuild)) {
        & "$(Find-MSBuild)" $args
    } else {
        Write-Error "Unable to locate MSBuild executable..."
    }
}

Set-Alias msbuild Invoke-MSBuild
