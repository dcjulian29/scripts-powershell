Function Add-DeployScript() 
{
  $dte.ItemOperations.AddNewItem("General\Text File", "Deploy.ps1")
}

Export-ModuleMember -Function Add-DeployScript
