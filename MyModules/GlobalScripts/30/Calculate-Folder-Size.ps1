function Calculate-Folder-Size
{
  param
  (
    [String]$folder = $pwd.Path
  )
  
  
  $files = Get-ChildItem $folder -Recurse
  $total = 0
  For ($i = 1; $i -le $files.Count-1; $i++)
  {
    Write-Progress -Activity "Calculating total size..." -status $files[$i].Name -percentComplete ($i / $files.Count * 100)
    $total += $files[$i].Length
    #Start-Sleep -Milliseconds 50
  }
 
  Write-Host $("Total size: {0:N2} MB" -f ($total / 1MB)) -ForegroundColor Cyan
}
