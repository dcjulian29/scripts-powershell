Function Add-Class($className) 
{
  if ($className.EndsWith(".cs") -eq $false)
  {
    $className = $className + ".cs"
  }

  $dte.ItemOperations.AddNewItem("Code\Class", $className)
}

Export-ModuleMember -Function Add-Class

Function Add-ViewModel($className) 
{
  if ($className.EndsWith(".cs") -eq $false)
  {
    $className = $className + ".cs"
  }

  $modelsDir = $dte.ActiveSolutionProjects[0].UniqueName.Replace(".csproj", "") + "\ViewModels"
  $dte.Windows.Item([EnvDTE.Constants]::vsWindowKindSolutionExplorer).Activate()
  $dte.ActiveWindow.Object.GetItem($modelsDir).Select([EnvDTE.vsUISelectionType]::vsUISelectionTypeSelect)
  $dte.ItemOperations.AddNewItem("Code\Class", $className)
}

Export-ModuleMember -Function Add-ViewModel
