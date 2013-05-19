Function Get-Threads
{
<#
.SYNOPSIS
    Returns the threads for the current process
#>
    if ($dte.Debugger.CurrentMode -ne 2)
    {
        Write-Warning "Use only when debugging..."
        return $null
    }
    
    $dte.Debugger.CurrentProgram.Threads
}

Function Get-Breakpoints
{
<#
.SYNOPSIS
    Returns all breakpoints
#>
    $dte.Debugger.BreakPoints | ForEach-Object { Get-Interface $_ ([ENVDTE80.Breakpoint2]) }
}

Export-ModuleMember -Function Get-Breakpoints

Function Disable-NonActiveThreads
{
<#
.SYNOPSIS
    Freezes all threads except the active thread.
#>
    if ($dte.Debugger.CurrentMode -ne 2)
    {
        Write-Warning "Use only when debugging..."
        return
    }
    
    $currThread = $dte.Debugger.CurrentThread.Id
    
    Get-Threads | Where-Object { $_.ID -ne $currThread } | `
            ForEach-Object { $_.Freeze() }
}

Export-ModuleMember -Function Disable-NonActiveThreads

Function Enable-NonActiveThreads
{
<#
.SYNOPSIS
    Unfreezes all threads except the active thread.
#>
    if ($dte.Debugger.CurrentMode -ne 2)
    {
        Write-Warning "Use only when debugging..."
        return
    }
    
    $currThread = $dte.Debugger.CurrentThread.Id
    
    Get-Threads | Where-Object { $_.ID -ne $currThread } | ForEach-Object { $_.Thaw() }
}

Export-ModuleMember -Function Enable-NonActiveThreads

Function Script:Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    )

    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}

Function Open-LastIntelliTraceRecording
{
<#
.SYNOPSIS
    IntelliTrace is great, but when you stop debugging the current debugging
    session's IntelliTrace log goes poof and disappears. This cmdlet opens
    the last run IntelliTrace log.
#>
    if ($dte.Debugger.CurrentMode -ne 1)
    {
        Write-Warning "Open-LastIntelliTraceRecording only works when not debugging."
        return $null
    }

    $ver = $dte.Version
    $regPath = "HKCU:\Software\Microsoft\VisualStudio\$ver\DialogPage\Microsoft.VisualStudio.TraceLogPackage.ToolsOptionAdvanced"
    if ( !(Test-Path $regPath ) -or
       ( (Get-ItemProperty -Path $regPath)."SaveRecordings" -eq "False") )
    {
        Write-Warning "You must set IntelliTrace to save the recordings."
        Write-Warning "Go to Tools/Options/IntelliTrace/Advanced and check 'Store IntelliTrace recordings in this directory'"
        return
    }
    
    if ( !(Test-RegistryValue $regPath "RecordingPath") )
    {
        Write-Warning "The RecordingPath property does not exist or is not set."
        return
    }
    
    $dir = (Get-ItemProperty -Path $regPath)."RecordingPath"
    
    # Get all the filenames from the recording path.
    $fileNames = Get-ChildItem -Path $dir | Sort-Object LastWriteTime -Descending
    if ($fileNames -ne $null)
    {
        
        # If the user has VSHOST debugging turned on for WPF/Console/WF apps,
        # current instance will be sitting there with no access set. I'll try opening
        # in order until I get one to open. This accounts for multiple instances
        # of VS running as they all share the same directory.
        for ($i = 0 ; $i -lt $fileNames.Length; $i++)
        {
            $toOpen = $fileNames[$i].FullName
            try
            {
                [void]$dte.ItemOperations.OpenFile($toOpen)
                return
            }
            catch
            {
            }
        }
    }
    else
    {
        Write-Warning "No IntelliTrace files are present"
    }
}

Export-ModuleMember -Function Open-LastIntelliTraceRecording
