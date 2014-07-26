$nodePath = Find-ProgramFiles 'nodejs\node.exe'

function npm()
{
  & "$(Split-Path $nodePath)\node_modules\npm\bin\npm-cli.js" $args;
}

function node()
{
  & $nodePath $args;
}
