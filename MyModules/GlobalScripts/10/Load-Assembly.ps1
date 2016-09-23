function Load-Assembly($assembly)
{
  if (test-path $assembly)
  {
    $assemblyPath = Get-Item $assembly
    [System.Reflection.Assembly]::LoadFrom($assemblyPath)
  }
  else
  {
    # Load from GAC
    [System.Reflection.Assembly]::LoadWithPartialName("$assembly")
  }
}
