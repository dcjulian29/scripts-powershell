if (Test-Path "$($env:SYSTEMDRIVE)\Tools\apps\gittfs")
{
  $env:Path = "$($env:SYSTEMDRIVE)\Tools\apps\gittfs;$env:PATH"
}

$tfPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\IDE\TF.exe') `
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

