function VsVars32($version = "11.0")
{
  $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
  $VsKey = get-ItemProperty $key
  $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
  $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
  $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
  $file = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")

  $cmd = "`"$file`" & set"
  cmd /c $cmd | Foreach-Object `
  {
    $p, $v = $_.split('=')
    Set-Item -path env:$p -value $v
  }

  $host.ui.rawui.WindowTitle = $host.ui.rawui.WindowTitle + " (Visual Studio " + $version + ")"
}
