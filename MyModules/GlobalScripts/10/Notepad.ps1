$notepadPath = Find-ProgramFiles 'Notepad++\notepad++.exe'

if ($notepadPath)
{
  Set-Alias notepad $notepadPath
  Set-Alias np $notepadPath
}
