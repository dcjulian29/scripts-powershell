$env:Path = "$env:Path;c:\bin\development-tools\git-tfs"

$tfPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\IDE\TF.exe'), `
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
