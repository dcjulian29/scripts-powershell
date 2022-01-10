Function Set-GUI
{   
  [Cmdletbinding()] 
  Param( 
    [ValidateSet("Full", "MinShell", "None")] 
    [String] $GuiType = "Full" 
  ) 

  Switch ($GuiType)
  { 
    "Full"
    {
      Add-WindowsFeature Server-Gui-Shell, Server-Gui-Mgmt-Infra 
      $RegPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" 
      Remove-ItemProperty -Path $RegPath -Name Shell -ErrorAction SilentlyContinue –Force 
    } 
    "MinShell"
    {
      Uninstall-WindowsFeature Server-Gui-Shell, Server-Gui-Mgmt-Infra
      Add-WindowsFeature Server-Gui-Shell 
      $RegPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" 
      Set-ItemProperty -Path $RegPath -Name Shell -Value 'PowerShell.exe -noExit -Command "$psversiontable"'  -Force  
    } 
    "None"
    {
      Uninstall-WindowsFeature Server-Gui-Shell, Server-Gui-Mgmt-Infra 
      $RegPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon"  
      Set-ItemProperty -Path $RegPath -Name Shell -Value 'PowerShell.exe -noExit -Command "$psversiontable"'  -Force
    }
    Default
    {
      "$GuiType unknown - enter Full, MinShell or None"
      return 
    } 
  }
  
  Restart-Computer 
}
