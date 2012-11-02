################################################################################
# This profile is loaded when the 
# nuget.exe Package Manager Console "host" is executed.
################################################################################

function Add-Class($className) 
{
  if ($className.EndsWith(".cs") -eq $false)
  {
    $className = $className + ".cs"
  }

  $dte.ItemOperations.AddNewItem("Code\Class", $className)
}

function Add-ViewModel($className) 
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
