function Load-Azure
{
  $azurePath = Find-ProgramFiles 'Microsoft SDKs\Windows Azure\PowerShell\Azure'
 
  if (($azurePath -eq "") -or (-not (Test-Path $azurePath)))
  {
    Write-Warning "Azure SDK is not installed. Cannot load module."
  }
  else
  {
    $files = Get-ChildItem "$($azurePath)\*.psd1"
    
    foreach ($file in $files)
    {
      "Loading Module $($file)..."
      Import-Module $file
    }
  }
}
