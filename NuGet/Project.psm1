Function Get-Type($kind)
{
  switch($kind) 
  {
    '{6BB5F8EE-4483-11D3-8BCF-00C04F8EC28C}' { 'File' }
    '{6BB5F8EF-4483-11D3-8BCF-00C04F8EC28C}' { 'Folder' }
    default { $kind }
  }
}

Function Get-Language($item) 
{
  if(!$item.FileCodeModel) 
  {
    return $null
  }

  $kind = $item.FileCodeModel.Language

  switch($kind) 
  {
    '{B5E9BD34-6D3E-4B5D-925E-8A43B79820B4}' { 'C#' }
    '{B5E9BD33-6D3E-4B5D-925E-8A43B79820B4}' { 'VB' }
    default { $kind }
  }
}

Function Recurse-ProjectItems($projectItems, $action) 
{
  $projectItems | % `
  {
    $obj = New-Object PSObject -Property @{
      ProjectItem = $_
      Type = Get-Type $_.Kind
      Language = Get-Language $_
    }
    
    & $action $obj
    
    if ($_.ProjectItems)
    {
      Recurse-ProjectItems $_.ProjectItems $action
    }
  }
}

Function Recurse-Project
{
  param(
    [parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$ProjectName,
    [parameter(Mandatory = $true)]$Action
  )
  
  Process 
  {
    if ($ProjectName)
    {
      $p = Get-Project $ProjectName
    }
    else
    {
      $p = Get-Project
    }
    
    $p | % { Recurse-ProjectItems $_.ProjectItems $Action }
  }
}
 
###############################################################################

Function Get-ProjectItems
{
<#
.SYNOPSIS
    Print all project items
#>
  Recurse-Project -Action {param($item) "`"$($item.ProjectItem.Name)`" is a $($item.Type)" }
}

Export-ModuleMember -Function Get-ProjectItems

Function Format-ProjectCode
{
<#
.SYNOPSIS
    Function to format all documents based on https://gist.github.com/984353
#>
  param
  (
    [parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$ProjectName
  )
  
  Process
  {
    $ProjectName | % `
    {
      Recurse-Project -ProjectName $_ -Action `
      {
        param($item)
        
        if ($item.Type -eq 'Folder' -or !$item.Language)
        {
          return
        }
        
        $window = $item.ProjectItem.Open('{7651A701-06E5-11D1-8EBD-00A0C90F26EA}')
        
        if ($window)
        {
          Write-Host "Processing `"$($item.ProjectItem.Name)`""
          
          [System.Threading.Thread]::Sleep(100)

          $window.Activate()
          $Item.ProjectItem.Document.DTE.ExecuteCommand('Edit.FormatDocument')
          $Item.ProjectItem.Document.DTE.ExecuteCommand('Edit.RemoveAndSort')
          $window.Close(1)
        }
      }
    }
  }
}

# Statement completion for project names
Register-TabExpansion 'Format-ProjectCode' @{ ProjectName = { Get-Project -All | Select -ExpandProperty Name } }

Export-ModuleMember -Function Format-ProjectCode
