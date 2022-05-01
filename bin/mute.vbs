Set WshShell = CreateObject("WScript.Shell")

'WshShell.SendKeys(Chr(&hAD))

WshShell.run "Sndvol"

WScript.Sleep 1500

WshShell.AppActivate("Volume control")
WshShell.SendKeys "{TAB}"
WshShell.SendKeys " "
WshShell.SendKeys "%{F4}"
