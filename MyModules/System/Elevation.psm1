Function Test-Elevation {
    Write-Verbose "Checking for elevation... "
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
        Write-Verbose "Not an administrator session!"
        Write-Error "This command requires elevation"
        return $false
    } else {
        Write-Verbose "Yes, this is an elevated session."
        return $true
    }
}

Function Invoke-ElevatedCommand {
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    [System.Diagnostics.Process]::Start($psi);
}

Function Invoke-ElevatedCommandAs {
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runasuser";
    [System.Diagnostics.Process]::Start($psi);
}

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

##############################################################################

Export-ModuleMember Test-Elevation
Export-ModuleMember Invoke-ElevatedCommand
Export-ModuleMember Invoke-ElevatedCommandAs
Export-ModuleMember Invoke-ElevatedScript

Set-Alias sudo Invoke-ElevatedCommand
Export-ModuleMember -Alias sudo

Set-Alias runas Invoke-ElevatedCommandAs
Export-ModuleMember -Alias runas

