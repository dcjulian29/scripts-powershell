$script:TfsUrl = ''
$script:TfsCollection = ''
$script:TfsNamespace = ''
$script:tfPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\IDE\TF.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\IDE\TF.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\IDE\TF.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 10.0\Common7\IDE\TF.exe')

Function tf() {
    Start-Process -FilePath $tfPath -ArgumentList $args -NoNewWindow -Wait    
}

Function Show-TfsHistory {
    param(
        [string]$Project,
        [string]$Filter
    )

    Write-Output "Getting history for $TfsNamespace/$Project..."

    tf --% history /server:"$TfsUrl/$TfsCollection" "$TfsNamespace/$Project" /recursive /noprompt /sort:ascending $Filter
}

Function Show-TfsHistoryForToday {
    param(
        [string]$Project
    )
    
    $StartDate = Get-Date -Format "yyyy-MM-dd"
    Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~ *"
}

Function Show-TfsHistoryForYesterday {
    param(
        [string]$Project
    )
    
    $EndDate = Get-Date -Format "yyyy-MM-dd"
    $StartDate = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
    Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~D$EndDate *"
}

Function Show-TfsHistoryForThisWeek {
    param(
        [string]$Project
    )
    
    $EndDate = Get-Date -Format "yyyy-MM-dd"

    switch ((Get-Date).DayOfWeek) {
        "Monday"      { $DayOfWeek = 0 }
        "Tuesday"     { $DayOfWeek = 1 }
        "Wednesday"   { $DayOfWeek = 2 }
        "Thursday"    { $DayOfWeek = 3 }
        "Friday"      { $DayOfWeek = 4 }
        "Saturday"    { $DayOfWeek = 5 }
        "Sunday"      { $DayOfWeek = 6 }

    }

    if ($DayOfWeek -eq 0) {
        ShowTfsHistoryForToday
    } else {
        $StartDate = (Get-Date).AddDays(0-$DayOfWeek).ToString('yyyy-MM-dd')
        Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~D$EndDate *"
    }
}

Function Show-TfsHistoryForLastWeek {
    param(
        [string]$Project
    )
    
    switch ((Get-Date).DayOfWeek) {
        "Monday"      { $DayOfWeek = 0 }
        "Tuesday"     { $DayOfWeek = 1 }
        "Wednesday"   { $DayOfWeek = 2 }
        "Thursday"    { $DayOfWeek = 3 }
        "Friday"      { $DayOfWeek = 4 }
        "Saturday"    { $DayOfWeek = 5 }
        "Sunday"      { $DayOfWeek = 6 }

    }

    if ($DayOfWeek -eq 0) {
        $EndDate = Get-Date -Format "yyyy-MM-dd"
    } else {
        $EndDate = (Get-Date).AddDays($DayOfWeek).ToString('yyyy-MM-dd')
    }

    $StartDate = (Get-Date).AddDays(0-$DayOfWeek).AddDays(-7).ToString('yyyy-MM-dd')

    Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~D$EndDate *"

}

Function Show-TfsHistoryForThisMonth {
    param(
        [string]$Project
    )
    
    $EndDate = Get-Date -Format "yyyy-MM-dd"
    $StartDate = Get-Date -Format "yyyy-MM-01"

    Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~D$EndDate *"

}

Function Show-TfsHistoryForLastMonth {
    param(
        [string]$Project
    )
    
    $EndDate = (Get-Date).AddDays(0-$(Get-Date).Day).ToString('yyyy-MM-dd')
    $StartDate = (Get-Date).AddDays(0-$(Get-Date).Day).ToString('yyyy-MM-01')

    Show-TfsHistory -Project $Project -Filter "/version:D$StartDate~D$EndDate *"

}

Function Clear-TfsProfile {
  Remove-Item -path env:TFS-PROFILE
}

Function Get-DevPath {
    $a = $($env:Path).IndexOf('development;')
    $b = $($env:Path).LastIndexOf(';', $a)

    if ($b -eq -1) { $b = 0 }

    $devt = $($env:Path).Substring($b, $a + 11)
    
    Write-Verbose "Development Script Directory is $devt"

    if ($devt.Length -eq 0) {
        Write-Error "Could not determine development tools directory."
    }
    
    return $devt
}

Function Get-TfsProfile {
    param (
        $ProfileName= $(Write-Error “An TFS profile name is required.”)
    )

    if ($ProfileName.Length -gt 0) {
        $devt = Get-DevPath

        $cmd = "`"$devt\tfs-profile-load.bat`" $ProfileName & set"

        $profileFound = $false

        cmd /c $cmd | Foreach-Object {
            $p, $v = $_.split('=')
            if ($p -eq 'TFS-PROFILE') {
                Set-Item -path env:$p -value $v
                $profileFound = $true
            }
        }
      
        if (-not $profileFound) {
            Write-Error "The TFS profile does not exist."
        }
    }
}

Function Initialize-TfsProfileSettings {
    param (
        $ProfileName= $(Write-Error “An TFS profile name is required.”)
    )
    
    $OriginalProfile = ${env:'TFS-PROFILE'}
  
    Get-TfsProfile $ProfileName

    $devt = Get-DevPath

    $cmd = "call `"$devt\_tfs_LoadSettings.cmd`" NO $ProfileName & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        if ($p -eq 'TFS-URL') {
            $script:TfsUrl = $v
        }
        if ($p -eq 'TFS-COLLECTION') {
            $script:TfsCollection = $v
        }
        if ($p -eq 'TFS-NS') {
            $script:TfsNamespace = $v
        }
    }

    Clear-TfsProfile
    if ($OriginalProfile.Length -gt 0) {
        ${env:'TFS-PROFILE'} = $OriginalProfile
    }
}

Function Get-TfsServerByProfile {
  param (
    $ProfileName= $(Write-Error “An TFS profile name is required.”)
  )

  Initialize-TfsProfileSettings $ProfileName

  $tfs = Get-TfsServer -Server $script:TfsUrl -Collection $script:TfsCollection

  return $tfs  
}

Function Get-TfsServer {
<#
.SYNOPSIS
    Connect to the specified TFS server collection and provide interfaces to Work Items, ???

.PARAMETER ServerName 
    The name of the TFS server to connect to

.PARMETER Collection
    The name of the TFS collection to connect to.

.NOTES
    AUTHOR: Julian Easterling <julian@julianscorner.com>
    LASTEDIT: 09/10/2013 09:03:06

.EXAMPLE     
    'TFSSERVER' | Get-TfsServer -Collection "DefaultCollection" | $_.WorkItemTracking.Query($WQL)  
    Connect to the specified TFS server and execute the query.
       
.EXAMPLE     
    $tfs = Get-TfsServer -Server "TFSSERVER" -Collection "DefaultCollection"
    Get a connection to the specified TFS server and store it in the $tfs variable.

#Requires -Version 2.0
#>
	[CmdletBinding()]
  param (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               Position=1)]   
    [string]$ServerName,                                   
    [Parameter(Mandatory = $true,
               Position=2)]   
    [string]$Collection
  )   
  BEGIN { }
  PROCESS {
    $c = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.Client")
    $propertiesToAdd = (
        ('VersionControlServer',
         'Microsoft.TeamFoundation.VersionControl.Client',
         'Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer'
        ),
        ('WorkItemStore',
         'Microsoft.TeamFoundation.WorkItemTracking.Client',
         'Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore'
        ),
        ('CommonStructureService',
         'Microsoft.TeamFoundation',
         'Microsoft.TeamFoundation.Server.ICommonStructureService'
        ),
        ('GroupSecurityService',
         'Microsoft.TeamFoundation', 
         'Microsoft.TeamFoundation.Server.IGroupSecurityService'
        )
    )
 
    $tfsPath = "$($ServerName)/$($Collection)"
    $tfs = $null
    [psobject] $tfs = [Microsoft.TeamFoundation.Client.TeamFoundationServerFactory]::GetServer($tfsPath)

    foreach ($entry in $propertiesToAdd) {
        $scriptBlock = '
            [System.Reflection.Assembly]::LoadWithPartialName("{0}") > $null
            $this.GetService([{1}])
        ' -f $entry[1],$entry[2]

        $tfs | Add-Member -Force ScriptProperty $entry[0] $ExecutionContext.InvokeCommand.NewScriptBlock($scriptBlock)
    }

    return $tfs
  }
  END { } 
}

Function Get-TfsWorkItem {
<#
.SYNOPSIS
    Get Work Items from TFS

.PARAMETER TfsServer 
    The TFS server object

.PARAMETER UserName 
    The UserName of the person

.NOTES
    AUTHOR: Julian Easterling <julian@julianscorner.com>
    LASTEDIT: 09/10/2013 09:24:17

.EXAMPLE     
    '12345' | Get-TfsWorkItem -param1 180   
    Describe what this example accomplishes 
       
.EXAMPLE     
    Get-TfsWorkItem -param2 @("text1","text2") -param1 180   
    Describe what this example accomplishes 

#Requires -Version 2.0
#>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]   
    [psobject] $TfsServer,                                   
    [Parameter(Mandatory = $false)]
    [string]$User = "@Me",
    [switch]$ExcludeActive,
    [switch]$ExcludeResolved,
    [switch]$ExcludeProposed,
    [switch]$ExcludeClosed
  )   
  BEGIN { }
  PROCESS {
    $wiql = @"
SELECT
  [Id], [State], [Title], [Assigned To]
FROM workitems
WHERE [Assigned To] = '$($User)'
"@

    if ($ExcludeActive) {
        $wiql = $wiql + " AND [State] <> 'Active' "
    }

    if ($ExcludeResolved) {
        $wiql = $wiql + " AND [State] <> 'Resolved' "
    }

    if ($ExcludeProposed) {
        $wiql = $wiql + " AND [State] <> 'Proposed' "
    }

    if ($ExcludeClosed) {
        $wiql = $wiql + " AND [State] <> 'Closed' "
    }
    
    $wiql = $wiql + " ORDER BY [Id]"

    $ws = $TfsServer.WorkItemStore

    $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
            @{Expression={$_.Fields["State"].value};Label="State";width=10}, `
            @{Expression={$_.Fields["Title"].value};Label="Title";width=94}

    if ($ws -ne $null) {
        $ws.Query($wiql) | Format-Table $line
    }
  }
  END { } 
}

Function Get-TfsWorkItemIveTouched {
<#
.SYNOPSIS
    Get TFS Work Items that I've been assigned to at some point during the items life cycle.

.PARAMETER TfsServer 
    The TFS server object

.NOTES
    AUTHOR: Julian Easterling <julian@julianscorner.com>
    LASTEDIT: 11/26/2013 08:42:00

.EXAMPLE     
    Get-TfsServer 'SERVER' | Get-TfsWorkItemIveTouched
    Get TFS Work Items that I've been assigned to at some point during the items life cycle.

.EXAMPLE     
    Get-TfsWorkItemIveTouched -TfsServer $TfsServer
    Get TFS Work Items that I've been assigned to at some point during the items life cycle.
    
#Requires -Version 2.0
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [int] $Days = -1
    )
    
    BEGIN { }
    PROCESS {
        $wiql = @"
SELECT
  [Id], [Work Item Type], [Title], [Assigned To], [State], [State Change Date]
FROM workitems
WHERE [Assigned To] ever @Me
"@

        if ($Days -gt -1) {
            $wiql = $wiql + " And [State Change Date] >= @Today-$Days"
        }

        $wiql = $wiql + " ORDER BY [State Change Date]"

        $ws = $TfsServer.WorkItemStore

        $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
                @{Expression={$_.Fields["Work Item Type"].value};Label="Type";width=5}, `
                @{Expression={$_.Fields["Title"].value};Label="Title";width=50}, `
                @{Expression={$_.Fields["Assigned To"].value};Label="AssignedTo";width=20}, `
                @{Expression={$_.Fields["State"].value};Label="State";width=10}, `
                @{Expression={$_.Fields["State Change Date"].value};Label="ChangedOn";width=25}

        if ($ws -ne $null) {
            $ws.Query($wiql) | Format-Table $line
        }
    }
    END { } 
}

Function Get-TfsWorkItemIveTouchedToday {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        Get-TfsWorkItemIveTouched -TfsServer $TfsServer -Days 0
    }
    END { } 
}

Function Get-TfsWorkItemIveTouchedYesterday {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        Get-TfsWorkItemIveTouched -TfsServer $TfsServer -Days 1
    }
    END { } 
}

Function Get-TfsWorkItemIveTouchedThisWeek {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        Get-TfsWorkItemIveTouched -TfsServer $TfsServer -Days 7
    }
    END { } 
}

Function Get-TfsWorkItemIveTouchedThisMonth {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        Get-TfsWorkItemIveTouched -TfsServer $TfsServer -Days 30
    }
    END { } 
}

Function Get-TfsWorkItemIveTouchedThisMonth {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        Get-TfsWorkItemIveTouched -TfsServer $TfsServer -Days 30
    }
    END { } 
}

Function Get-TfsMyWorkItemChangedYesterday {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        $today = [datetime]::Today.ToString()
        $yesterday = (([datetime]::Today).AddDays(-1)).ToString()
        $wiql = @"
SELECT
  [Id], [Work Item Type], [Title], [State]
FROM workitems
WHERE [Assigned To] = @Me
AND ([System.ChangedDate] >= '$yesterday' AND [System.ChangedDate] < '$today')
ORDER BY [Id]
"@

        $ws = $TfsServer.WorkItemStore

        $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
                @{Expression={$_.Fields["Work Item Type"].value};Label="Type";width=5}, `
                @{Expression={$_.Fields["State"].value};Label="State";width=10}, `
                @{Expression={$_.Fields["Title"].value};Label="Title";width=89}

        if ($ws -ne $null) {
            $ws.Query($wiql) | Format-Table $line
        }
    }
    END { } 
}

Function Get-TfsMyWorkItemChangedToday {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer
    )
    
    BEGIN { }
    PROCESS {
        $today = [datetime]::Today.ToString()
        $wiql = @"
SELECT
  [Id], [Work Item Type], [Title], [State]
FROM workitems
WHERE [Assigned To] = @Me
AND ([System.ChangedDate] >= '$today')
ORDER BY [Id]
"@

        $ws = $TfsServer.WorkItemStore

        $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
                @{Expression={$_.Fields["Work Item Type"].value};Label="Type";width=5}, `
                @{Expression={$_.Fields["State"].value};Label="State";width=10}, `
                @{Expression={$_.Fields["Title"].value};Label="Title";width=89}

        if ($ws -ne $null) {
            $ws.Query($wiql) | Format-Table $line
        }
    }
    END { } 
}

Function Update-WorkItem {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]   
        [psobject] $WorkItem,

        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        [string] $Field,
        
        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        $Value
    )

    BEGIN { }
    PROCESS {
        if ($WorkItem -is [Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItem]) {
            if (!$WorkItem.IsOpen) {
                $WorkItem.open()
            }

            Write-Verbose "Updating `"$Field`" to `"$Value`" on work item $($WorkItem.Id)..."
            $WorkItem.Fields[$Field].Value = $Value
            $WorkItem.Save() | Out-Null
            return $WorkItem
        } else {
            throw "Not a valid TFS work item!"
        }
    }
    END { } 
}

Function Set-WorkItemProposed {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        Update-WorkItem $WorkItem "State" "Proposed" | Out-Null
    }
    END { }
}

Function Set-WorkItemActive {
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        Update-WorkItem $WorkItem "State" "Active" | Out-Null
    }
    END { }
}

Function Set-WorkItemClosed {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        $RemainingWork = $WorkItem.Fields["Remaining Work"].Value

        if ($RemainingWork -gt 0) {
            throw "Work item $($WorkItem.Id) still has remaining work!"
        }

        Update-WorkItem $WorkItem "State" "Closed" | Out-Null
    }
    END { }
}

Function Set-WorkItemResolved {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        $RemainingWork = $WorkItem.Fields["Remaining Work"].Value

        if ($RemainingWork -gt 0) {
            throw "Work item $($WorkItem.Id) still has remaining work!"
        }

        Update-WorkItem $WorkItem "State" "Resolved" | Out-Null
    }
    END { }
}

Function Set-WorkItemCompletedTime {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Hours
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        Update-WorkItem $WorkItem "Completed Work" $Hours | Out-Null
    }
    END { }
}

Function Set-WorkItemOriginalEstimate {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Hours
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        $Estimate = $WorkItem.Fields["Original Estimate"].Value

        if ($Estimate.Length -gt 0) {
            throw "Work item $($WorkItem.Id) already has an original estimate!"
        }

        Update-WorkItem $WorkItem "Original Estimate" $Hours | Out-Null
        $WorkItem | Set-WorkItemRemainingTime -Hours $Hours
        $WorkItem | Set-WorkItemCompletedTime -Hours 0
    }
    END { }
}

Function Set-WorkItemRemainingTime {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Hours
    )

    BEGIN { }
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }
        
        Update-WorkItem $WorkItem "Remaining Work" $Hours | Out-Null
    }
    END { }
}

Function Update-WorkItemTime {
   [CmdletBinding()]
    param (
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(ParameterSetName="p1", Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id,

        [Parameter(ParameterSetName="p2", Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem,

        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Hours
    )

    BEGIN {}
    PROCESS {
        if ($PsCmdlet.ParameterSetName -eq "p1") {    
            $WorkItem = ($TfsServer.WorkItemStore).GetWorkItem($Id)    
        }

        $RemainingWork = $WorkItem.Fields["Remaining Work"].Value
        $CompletedWork = $WorkItem.Fields["Completed Work"].Value

        $CompletedWork = $CompletedWork + $Hours
        $RemainingWork = $RemainingWork - $Hours
        
        if ($RemainingWork -lt 0) { $RemainingWork = 0 }
        
        Update-WorkItem $WorkItem "Remaining Work" $RemainingWork | Out-Null
        Update-WorkItem $WorkItem "Completed Work" $CompletedWork | Out-Null
    }
    END {}
}

Function Get-WorkItemTime {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id
    )

    BEGIN {}
    PROCESS {
        $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
                @{Expression={$_.Fields["Completed Work"].value};Label="Completed";width=9}, `
                @{Expression={$_.Fields["Remaining Work"].value};Label="Remaining";width=9}, `
                @{Expression={$_.Fields["Title"].value};Label="Title";width=82}

        $WorkItem | Format-Table $line
    }
    END {}
}

Function Get-WorkItem {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)]   
        [int] $Id
    )
    
    BEGIN {}
    PROCESS {
        $ws = $TfsServer.WorkItemStore
        $wi = $ws.GetWorkItem($Id)
        
        # TODO: Add Error Handling Here.

        return $wi
    }
    END {}
}

Function Get-WorkItemState {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN {}
    PROCESS {    
        Write-Output $wi.Fields["State"].Value
    }
    END {}
}

Function Get-WorkItemDetails {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $WorkItem
    )

    BEGIN {}
    PROCESS {    
        Write-Output $wi.Fields["Task Detail"].Value
    }
    END {}
}

Function Get-WorkItems {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,                                   
        [Parameter(Mandatory = $false)]
        [string]$User,
        [string]$Project,
        [string[]]$ExcludedStates,
        [switch]$JustMine
    )
    
    BEGIN { }
    PROCESS {
        $wiql = "SELECT * FROM workitems"

         if ($ExcludedStates.Count -gt 0) {
            foreach ($state in $ExcludedStates) {
                $filter = $filter + "AND [State] <> '$state' "
            }
        }

        if ($JustMine) {
            if ($User.Length -gt 0) {
                Write-Warning "When selecting just your work items, you can not specify a user to include in the filter."
            }

            $filter = $filter + "AND [Assigned To] = @Me "
        } else {
            if ($User.Length -gt 0) {
                $filter = $filter + "AND [Assigned To] = '$User' "
            }
        }

        if ($Project.Length -gt 0) {
            $filter = $filter + "AND [System.TeamProject] = '$Project' "
        }

        if ($filter.Length -gt 0) {
            $wiql = "$wiql WHERE $($filter.SubString(4))"
        }
        
        return ($TfsServer.WorkItemStore).Query($wiql)
  }
  END { } 
}

Function New-TfsTaskForUserStory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]   
        [psobject] $TfsServer,
        [Parameter(Mandatory = $true)]   
        [int] $UserStory,
        [Parameter(Mandatory = $true)]   
        [string] $Title,
        [Parameter(Mandatory = $true)]   
        [int] $Hours
    )
    
    BEGIN { }
    PROCESS {
        $wiql = @"
SELECT
  [Work Item Type], [Title] 
FROM workitems 
WHERE [Id] = $UserStory
"@

        $ws = $TfsServer.WorkItemStore

        if ($ws -ne $null) {
            $story = $ws.Query($wiql) 

            if ($story -ne $null) {
                if ($story.Type.Name -ne "User Story") {
                    throw "The provided work item is not a User Story."
                }
            }
        }

        $projectName = ($story.Fields | ? { $_.Name -eq "Team Project" }).Value
        $project = $ws.Projects | ? { $_.Name -eq $projectName }
        $taskItem = $project.WorkItemTypes | ? { $_.Name -eq "Task" }

        $workItem = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItem($taskItem)
        $workItem.Title = $Title

        $linkType = $ws.WorkItemLinkTypes[[Microsoft.TeamFoundation.WorkItemTracking.Client.CoreLinkTypeReferenceNames]::Hierarchy]
        $link = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemLink($linkType.ReverseEnd, $story.Id)

        $workItem.WorkItemLinks.Add($link) | Out-Null

        $activity = $workItem.Fields | ? { $_.Name -eq "Activity" }
        $activity.Value = "Implementation"

        $iteration = $workItem.Fields | ? { $_.Name -eq "Iteration Path" }
        $iteration.Value = ($story.Fields | ? { $_.Name -eq "Iteration Path" }).Value

        $remaining = $workItem.Fields | ? { $_.Name -eq "Remaining Work" }
        $remaining.Value = $Hours

        $workItem.Save()

        Write-Output "Created a new task #$($workItem.Id)"
    }
    END { } 
}

###############################################################################

Export-ModuleMember Get-WorkItems
Export-ModuleMember Set-WorkItemOriginalEstimate
Export-ModuleMember Set-WorkItemRemainingTime
Export-ModuleMember Set-WorkItemCompletedTime
Export-ModuleMember Clear-TfsProfile
Export-ModuleMember Get-TfsMyWorkItemChangedToday
Export-ModuleMember Get-TfsMyWorkItemChangedYesterday
Export-ModuleMember Get-TfsProfile
Export-ModuleMember Get-TfsServer
Export-ModuleMember Get-TfsServerByProfile
Export-ModuleMember Get-TfsWorkItem
Export-ModuleMember Get-TfsWorkItemIveTouched
Export-ModuleMember Get-TfsWorkItemIveTouchedToday
Export-ModuleMember Get-TfsWorkItemIveTouchedYesterday
Export-ModuleMember Get-TfsWorkItemIveTouchedThisWeek
Export-ModuleMember Get-TfsWorkItemIveTouchedThisMonth
Export-ModuleMember Set-WorkItemActive
Export-ModuleMember Set-WorkItemClosed
Export-ModuleMember Set-WorkItemProposed
Export-ModuleMember Set-WorkItemResolved
Export-ModuleMember Get-WorkItem
Export-ModuleMember Get-WorkItemState
Export-ModuleMember Get-WorkItemDetails
Export-ModuleMember Update-WorkItemTime
Export-ModuleMember Update-WorkItem
Export-ModuleMember Get-WorkItemTime
Export-ModuleMember New-TfsTaskForUserStory

Set-Alias gtfs Get-TfsServer
Set-Alias gtwi Get-TfsWorkItem
Set-Alias tfs-profile-clear Clear-TfsProfile
Set-Alias tfs-profile-load Get-TfsProfile

Export-ModuleMember -Alias gtfs
Export-ModuleMember -Alias gtwi
Export-ModuleMember -Alias tfs-profile-clear
Export-ModuleMember -Alias tfs-profile-load


Export-ModuleMember Show-TfsHistory
Set-Alias tfs-history Show-TfsHistory
Export-ModuleMember -Alias tfs-history

Export-ModuleMember Show-TfsHistoryForToday
Set-Alias tfs-history-today Show-TfsHistoryForToday
Export-ModuleMember -Alias tfs-history-today

Export-ModuleMember Show-TfsHistoryForYesterday
Set-Alias tfs-history-yesterday Show-TfsHistoryForYesterday
Export-ModuleMember -Alias tfs-history-yesterday

Export-ModuleMember Show-TfsHistoryForThisWeek
Set-Alias tfs-history-thisweek Show-TfsHistoryForThisWeek
Export-ModuleMember -Alias tfs-history-thisweek

Export-ModuleMember Show-TfsHistoryForLastWeek
Set-Alias tfs-history-lastweek Show-TfsHistoryForLastWeek
Export-ModuleMember -Alias tfs-history-lastweek

Export-ModuleMember Show-TfsHistoryForThisMonth
Set-Alias tfs-history-thismonth Show-TfsHistoryForThisMonth
Export-ModuleMember -Alias tfs-history-thismonth

Export-ModuleMember Show-TfsHistoryForLastMonth
Set-Alias tfs-history-lastmonth Show-TfsHistoryForLastMonth
Export-ModuleMember -Alias tfs-history-lastmonth
