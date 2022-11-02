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

#http://stackoverflow.com/questions/40863475/starting-non-elevated-prompt-from-elevated-session
function Start-ProcessNonElevated {
  [CmdletBinding()]
  param (
    [string] $Command,
    [switch] $UsePowerShell
  )

  $svc = Get-Service Schedule -ea 0
  if ($svc -and $svc.Status -ne 'Running') {
    throw 'Start-ProcessNonElevated requires running Task Scheduler service'
  }

  $res = @{}

  $tmp_base  = [System.IO.Path]::GetTempFileName()
  $tmp_base  = $tmp_base -replace '\.tmp$'
  $tmp_name  = Split-Path $tmp_base -Leaf
  $task_name = "Start-ProcessNonElevated-$tmp_name"
  Write-Verbose "Temporary files: $tmp_base"

  if ($UsePowershell) {
    @(
      '$r = "{0}"' -f $tmp_base
      ". {{`n{0}`n}} >`"`$r.out.log`" 2>`"`$r.err.log`"" -f $Command
    ) -join "`n" | Out-String | Out-File "$tmp_base.ps1"

    $Command = "powershell -NoProfile -ExecutionPolicy Bypass " `
      + "-WindowStyle Hidden -NoLogo -NonInteractive -File '$tmp_base.ps1'"
  }

  Write-Verbose "Creating scheduled task for command:`n$Command"
  schtasks.exe /Create /RU $env:USERNAME /TN $task_name /SC ONCE /ST 00:00 /F /TR $Command *> "$tmp_base.schtasks.log"
  schtasks.exe /run /tn $task_name *>> "$tmp_base.schtasks.log"

  Write-Verbose 'Waiting for scheduled task to finish'

  do {
    $status = schtasks /query /tn $task_name /FO csv | ConvertFrom-Csv | Select-Object -expand Status
    Start-Sleep 1
  } until ($status -eq 'Ready')

  schtasks.exe /delete /F /tn $task_name *>> "$tmp_base.schtasks.log"

  if ($UsePowershell) {
    $res = @{
      out = Get-Content "$tmp_base.out.log" -ea 0
      err = Get-Content "$tmp_base.err.log" -ea 0
    }
  }

  return $res
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
