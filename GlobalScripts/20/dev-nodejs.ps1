$nodePath = Find-ProgramFiles 'nodejs\node.exe'
$env:Path = "$env:Path;$($nodePath)"

function npm()
{
  & $nodePath "$(Split-Path $nodePath)\.\node_modules\npm\bin\npm-cli.js" $args;
}

function node()
{
  & $nodePath $args;
}
