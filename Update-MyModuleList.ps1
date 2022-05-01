$mine = "$PSScriptRoot\mine.json"
$dev = "$(Get-DefaultCodeFolder)\scripts-powershell\modules"

$modules = @()

foreach ($module in (Get-ChildItem -Path $dev -Directory).BaseName) {
  if (Test-Path "$dev/$module/$module.psd1") {
    $modules += $module
  }
}

$modules | ConvertTo-Json | Out-File -Encoding ascii -FilePath $mine
