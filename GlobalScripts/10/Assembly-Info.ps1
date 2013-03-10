function Assembly-Info
{
  param
  (
    $assembly= $(throw “An assembly name is required.”)
  )

  if (test-path $assembly)
  {
    $assemblyPath = Get-Item $assembly
    $loadedAssembly = [System.Reflection.Assembly]::LoadFrom($assemblyPath)
  }
  else
  {
    # Load from GAC
    $loadedAssembly = [System.Reflection.Assembly]::LoadWithPartialName("$assembly")
  }

  $name = $loadedAssembly.GetName().name
  $version =  $loadedAssembly.GetName().version

  "{0} [{1}]" -f $name, $version
}

