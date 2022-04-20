Function Assert-Elevation {
    Write-Verbose "Checking for elevation... "
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
        Write-Error "This command requires elevation"
        return $false
    }

    return $true
}

Function Test-Elevation {
    Write-Verbose "Checking for elevation... "
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
        Write-Verbose "No, this is not an elevated session."
        return $false
    } else {
        Write-Verbose "Yes, this is an elevated session."
        return $true
    }
}

Function Invoke-ElevatedCommand {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$File,
        [string]$ArgumentList,
        [switch]$Wait = $false
    )

    if (-not (Test-Elevation)) {
        $process = New-Object System.Diagnostics.ProcessStartInfo $File
        $process.Arguments = $ArgumentList
        $process.Verb = "runas"

        $handle = [System.Diagnostics.Process]::Start($process)

        if ($Wait) {
            $handle.WaitForExit()
        }
    } else {
        if ($Wait) {
            Start-Process -FilePath $File -ArgumentList $ArgumentList -Wait
        } else {
            Start-Process -FilePath $File -ArgumentList $ArgumentList
        }
    }
}

Set-Alias sudo Invoke-ElevatedCommand

Function Invoke-ElevatedCommandAs {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$File,
        [string]$ArgumentList,
        [switch]$Wait = $false
    )

    $process = New-Object System.Diagnostics.ProcessStartInfo $File
    $process.Arguments = $Arguments
    $process.Verb = "runasuser"

    $handle = [System.Diagnostics.Process]::Start($process)

    if ($Wait) {
        $handle.WaitForExit()
    }
}

Set-Alias runas Invoke-ElevatedCommandAs

Function Invoke-ElevatedScript {
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock,
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,
        [switch] $EnableProfile
    )

    BEGIN {
        $inputItems = New-Object System.Collections.ArrayList
    }

    PROCESS {
        $null = $inputItems.Add($inputObject)
    }

    END {
        $outputFile = [IO.Path]::GetTempFileName()
        $inputFile = [IO.Path]::GetTempFileName()
        $inputItems.ToArray() | Export-CliXml -Depth 1 $inputFile
        $commandString = "Set-Location '$($pwd.Path)'; " +
            "`$output = Import-CliXml '$inputFile' | " +
            "& {" + $scriptblock.ToString() + "} 2>&1; " +
            "Export-CliXml -Depth 1 -In `$output '$outputFile'"

        $commandBytes = [System.Text.Encoding]::Unicode.GetBytes($commandString)
        $encodedCommand = [Convert]::ToBase64String($commandBytes)
        $commandLine = "-EncodedCommand $encodedCommand"

        if (-not $EnableProfile) {
            $commandLine = "-NoProfile {0}" -f $commandLine
        }

        $process = Start-Process -FilePath (Get-Command powershell).Definition `
            -ArgumentList $commandLine -Verb RunAs `
            -WindowStyle Hidden `
            -Passthru

        $process.WaitForExit()

        if ((Get-Item $outputFile).Length -gt 0) {
            Import-CliXml $outputFile
        }

        Remove-Item $outputFile
        Remove-Item $inputFile
    }
}

Function Invoke-ElevatedExpression {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Command
    )

    $commandString = "try { Invoke-Expression `"" + $Command + "`"} catch { throw }"

    $commandBytes = [System.Text.Encoding]::Unicode.GetBytes($commandString)
    $encodedCommand = [Convert]::ToBase64String($commandBytes)

    $commandLine = "-NoProfile -EncodedCommand $encodedCommand"

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = (Get-Command powershell).Definition
    $processInfo.RedirectStandardError = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.Arguments = $commandLine
    $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $processInfo.Verb = "runas"
    $processInfo.WorkingDirectory = Get-Location
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null

    $process.WaitForExit()

    Write-Output $process.StandardOutput.ReadToEnd()

    if ( $process.ExitCode -ne 0) {
        Write-Error $process.StandardError.ReadToEnd()
    }
}

Function Start-RemoteProcess {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Command
    )

    ([WMICLASS]"\\$ComputerName\ROOT\CIMV2:win32_process").Create($Command)
}
