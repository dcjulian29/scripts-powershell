Function Get-TfsServer
{<#
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
  param
  (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               Position=1)]   
    [string]$ServerName,                                   
    [Parameter(Mandatory = $true,
               Position=2)]   
    [string]$Collection
  )   
  BEGIN
  { }
  PROCESS
  {
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

    foreach ($entry in $propertiesToAdd) `
    {
        $scriptBlock = '
            [System.Reflection.Assembly]::LoadWithPartialName("{0}") > $null
            $this.GetService([{1}])
        ' -f $entry[1],$entry[2]

        $tfs | Add-Member -Force ScriptProperty $entry[0] $ExecutionContext.InvokeCommand.NewScriptBlock($scriptBlock)
    }

    return $tfs
  }
  END
  { } 
}

Function Get-TfsWorkItem
{<#
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
  param
  (
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
  BEGIN
  { }
  PROCESS
  {
    $wiql = @"
SELECT
  [Id], [State], [Title], [Assigned To]
FROM workitems
WHERE [Assigned To] = '$($User)'
"@

    if ($ExcludeActive)
    {
    $wiql = $wiql + " AND [State] <> 'Active' "
    }

    if ($ExcludeResolved)
    {
    $wiql = $wiql + " AND [State] <> 'Resolved' "
    }

    if ($ExcludeProposed)
    {
    $wiql = $wiql + " AND [State] <> 'Proposed' "
    }

    if ($ExcludeClosed)
    {
    $wiql = $wiql + " AND [State] <> 'Closed' "
    }

    
    $wiql = $wiql + " ORDER BY [Id]"

    $ws = $TfsServer.WorkItemStore

    $line = @{Expression={$_.Fields["Id"].value};Label="ID";width=6}, `
            @{Expression={$_.Fields["State"].value};Label="State";width=10}, `
            @{Expression={$_.Fields["Title"].value};Label="Title";width=94}

    if ($ws -ne $null)
    {
        $ws.Query($wiql) | Format-Table $line
    }
  }
  END
  { } 
}


Set-Alias gtfs Get-TfsServer
Set-Alias gtwi Get-TfsWorkItem


Export-ModuleMember Get-TfsServer
Export-ModuleMember Get-TfsWorkItem

Export-ModuleMember -Alias gtfs
Export-ModuleMember -Alias gtwi
