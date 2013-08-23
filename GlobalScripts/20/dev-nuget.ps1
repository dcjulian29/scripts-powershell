function nuget-profile-clear
{
  Remove-Item -path env:NUGET-PROFILE
}

function nuget-profile-load
{
  param
  (
    $nuget= $(Write-Error “An NuGet profile name is required.”)
  )

  if ($nuget.Length -gt 0)
  {
    # First let's load the "dev-path" script to get the path to the DEV-Tools
    $devt = ""
    $cmd = "path-dev.bat & set PATH"
    cmd /c $cmd | Foreach-Object `
    {
      $p, $v = $_.split('=')
      if ($p.ToLower() -eq 'path')
      {
        $a = $v.IndexOf('development-tools;')
        $b = $v.LastIndexOf(';', $a)
        if ($b -eq -1) { $b = 0 }
        $devt = $v.Substring($b, $a + 17)
      }
    }

    if ($devt.Length -eq 0)
    {
      Write-Error "Could not determine development tools directory."
    }
    else
    {
      $cmd = "`"$devt\nuget-profile-load.bat`" $nuget & set"

      $profileFound = $false
      cmd /c $cmd | Foreach-Object `
      {
        $p, $v = $_.split('=')
        if ($p -eq 'NUGET-PROFILE')
        {
          Set-Item -path env:$p -value $v
          $profileFound = $true
        }
      }
      
      if (-not $profileFound)
      {
        Write-Error "The NuGet profile does not exist."
      }
    }
  }
}