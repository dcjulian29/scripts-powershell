Function Purge-Files
{
  param
  (
    [string]$folder= $(throw “A directory name is required.”),
    [string]$filter= $(throw “A file match filter is required.”),
    [int]$age= $(throw “Provide the number of days old.”)
  )

  if (Test-Path $folder)
  {
    $attemps = 0
    $done = $false

    while (($attempts -lt 20) -and (-not $done))
    {
      $files = 	Get-ChildItem -Path $folder -Filter $filter -Recurse `
        | where { [Datetime]::Now -gt $_.LastWriteTime.AddDays($age) }

      if ($files -eq $null)
      {
        $done = $true
      }
      else
      {
        Write-Host "Attempt $($attempts + 1)..."
        $files | Remove-Item  -Force -Recurse -ErrorAction SilentlyContinue
        $attempts++
      }
    }

    if ($attempts -eq 20)
    {
      ""
      Write-Warning "Unable to complete the purge process... The following file were not purged:"
      $files = 	Get-ChildItem -Path $folder -Filter $filter -Recurse `
      | where { [Datetime]::Now -gt $_.LastWriteTime.AddDays($age) }
      
      foreach ($file in $files)
      {
        Write-Host -ForeGroundColor Red "   $($file.FullName)"
      }
      ""
    }
    else
    {
      ""
      Write-Host "Pruge operation complete..." -ForeGroundColor Magenta
      ""
    }
  }
}

