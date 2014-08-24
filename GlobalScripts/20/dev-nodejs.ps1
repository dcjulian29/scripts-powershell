function npm()
{
  & "$(Split-Path (Find-ProgramFiles 'nodejs\node.exe'))\npm.cmd" $args;
}

function node()
{
  & "Find-ProgramFiles 'nodejs\node.exe'" $args;
}
