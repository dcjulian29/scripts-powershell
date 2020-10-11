function Get-CakeBuildBootstrapper {
    if (Test-Path build.ps1) {
        Remove-Item -Confirm -Path build.ps1
    }

    if (Test-Path build.ps1) {
        throw "Cake.Build bootstraper file still exists! Can't continue..."
    }

    Invoke-WebRequest https://cakebuild.net/download/bootstrapper/windows -OutFile build.ps1
}

function Get-CodeCoverageReport {
    if (-not (Test-Path build.cake)) {
        Write-Warning "This project doesn't support Cake.Build so cannot generate Code coverage currently."
        return
    }

    if (-not (Test-Path "tools")) {
        Write-Warning "This project doesn't contain the Tools directory."
        return
    }

    $openCover = (Get-ChildItem -Filter "OpenCover.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "/tools/OpenCover.Console.exe"

    $reportGenerator = (Get-ChildItem -Filter "ReportGenerator.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "/tools/net47/ReportGenerator.exe"

    $xunit = (Get-ChildItem -Filter "xunit.runner.console.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "/tools/net472/xunit.console.exe"


    if (-not ($openCover -and $reportGenerator -and $xunit)) {
        Write-Warning "Code Coverage tools not found."
        return
    }

    $coverageFolder = Join-Path $([System.IO.Path]::GetTempPath()) $([System.Guid]::NewGuid().Guid)

    if (Test-Path $coverageFolder) {
        Remove-Item $coverageFolder -Recurse -Force
    }

    New-Item -ItemType Directory -Path $coverageFolder | Out-Null

    $unitTest = "$((Get-Location).Path)/UnitTests/bin/Debug/UnitTests.dll"

    if (-not (Test-Path $unitTest)) {
        Write-Warning "UnitTest project output DLL not found."
        return
    }

    $cmd = "$openCover --% " `
        + "-target:""$xunit"" " `
        + "-targetargs:""\""$unitTest\"" -parallel all -maxthreads unlimited -noshadow -nocolor -verbose"" " `
        + "-register:user " `
        + "-output:""$coverageFolder\coverage.xml"" " `
        + "-filter:""+[*]* -[UnitTests]* -[xunit.*]* -[Common.*]*"" " `
        + "-excludebyattribute:System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverageAttribute " `
        + "-excludebyfile:""*Designer.csb*\\*.g.csb*.*.g.i.cs"""

    Invoke-Expression -Command $cmd

    $cmd = "$reportGenerator --% " `
        + "-reports:""$coverageFolder/coverage.xml"" " `
        + "-targetdir:""$coverageFolder"""

    Invoke-Expression -Command $cmd

    Start-Process "$coverageFolder/index.htm"
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

function Get-UnitTestReport {
    if (-not (Test-Path build.cake)) {
        Write-Warning "This project doesn't support Cake.Build so cannot generate Code coverage currently."
        return
    }

    if (-not (Test-Path "tools")) {
        Write-Warning "This project doesn't contain the Tools directory."
        return
    }

    $xunit = (Get-ChildItem -Filter "xunit.runner.console.*" -Path "tools" `
        | Sort-Object Name -Descending `
        | Select-Object -First 1).FullName + "/tools/net472/xunit.console.exe"


    if (-not ($xunit)) {
        Write-Warning "Xunit not found."
        return
    }

    $unitTest = "$((Get-Location).Path)/UnitTests/bin/Debug/UnitTests.dll"

    if (-not (Test-Path $unitTest)) {
        Write-Warning "UnitTest project output DLL not found."
        return
    }

    $report = "$(Join-Path $([System.IO.Path]::GetTempPath()) $([System.Guid]::NewGuid().Guid)).htm"
    $cmd = "& ""$xunit"" --% " `
        + """$unitTest"" -parallel all -maxthreads unlimited -noshadow -nocolor -verbose " `
        + "-html ""$report"""

    Invoke-Expression -Command $cmd
    Start-Process "$report"
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

function Show-CoverageReport {
    param (
        [String] $ReportIndex = ".\.build\coverage\index.htm"
    )

    if (Test-Path $ReportIndex) {
            Start-Process $reportIndex
    }
}
