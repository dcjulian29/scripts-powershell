Function Format-SolutionCode
{
<#
.SYNOPSIS
    Function to format all Code Files in the current solution
#>
  Get-Project -All | Format-ProjectCode
}

Export-ModuleMember -Function Format-SolutionCode

Function Get-SolutionItems
{
<#
.SYNOPSIS
    Print all project items in the solution
#>
  Get-Project -All | Recurse-Project -Action {param($item) "`"$($item.ProjectItem.Name)`" is a $($item.Type)" }
}
