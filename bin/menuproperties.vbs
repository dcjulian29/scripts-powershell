Set Args = WScript.Arguments

If Args.Count = 1 Then
  Dir = Args(0)
  If Dir = "UP" Or Dir = "DOWN" Then
    Dir = "{" + Args(0) + "}"

    Set WshShell = CreateObject("WScript.Shell")

    WshShell.run "Rundll32.exe C:\WINDOWS\SYSTEM32\SHELL32.DLL,Options_RunDLL 1"

    WScript.Sleep 1500

    WshShell.AppActivate("Taskbar and Start Menu Properties")
    WshShell.SendKeys "%T"
    For I=1 To 4
      WshShell.SendKeys DIR
    Next
    WshShell.SendKeys "{ENTER}"
  End If
End If