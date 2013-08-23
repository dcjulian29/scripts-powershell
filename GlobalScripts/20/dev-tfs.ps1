$env:Path = "$env:Path;c:\bin\development-tools\git-tfs"

$tfPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\IDE\TF.exe') `
  (Find-ProgramFiles 'Microsoft Visual Studio 10.0\Common7\IDE\TF.exe')

function tf()
{
  & $tfPath $args;
}

function tfHistory($path, $knownGoodVersion)
{
  if ($knownGoodVersion)
  {
    tf hist $path /noprompt /recursive /stopafter:$knownGoodVersion
  }
  else
  {
    tf hist $path /noprompt /recursive
  }
}

function tfs-profile-clear
{
  Remove-Item -path env:TFS-PROFILE
}

function tfs-profile-load
{
  param
  (
    $tfs= $(Write-Error “An TFS profile name is required.”)
  )

  if ($tfs.Length -gt 0)
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
      $cmd = "`"$devt\tfs-profile-load.bat`" $tfs & set"

      $profileFound = $false
      cmd /c $cmd | Foreach-Object `
      {
        $p, $v = $_.split('=')
        if ($p -eq 'TFS-PROFILE')
        {
          Set-Item -path env:$p -value $v
          $profileFound = $true
        }
      }
      
      if (-not $profileFound)
      {
        Write-Error "The TFS profile does not exist."
      }
    }
  }
}