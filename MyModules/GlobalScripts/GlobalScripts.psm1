Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -Recurse | % `
{
    . $_.FullName
}

Get-ChildItem -Path $PSScriptRoot -Filter *.psm1 -Recurse | % `
{
    Import-Module $_.FullName -Force -DisableNameChecking
}

##############################################################################

Export-ModuleMember Check-Url
Export-ModuleMember Count-Object
Export-ModuleMember Get-Hash
Export-ModuleMember Get-Share
Export-ModuleMember Get-SubNetItems
Export-ModuleMember Load-Assembly
Export-ModuleMember midnight
Export-ModuleMember New-Share
Export-ModuleMember Notepad
Export-ModuleMember Set-GUI
Export-ModuleMember Test-Port
Export-ModuleMember touch
Export-ModuleMember Calculate-Folder-Size
Export-ModuleMember Compare-OPML
Export-ModuleMember Enable-RemoteDesktop
Export-ModuleMember Find-NoRssPostInMonths
Export-ModuleMember Install-WindowsUpdate
Export-ModuleMember Pin-Taskbar
Export-ModuleMember Reset-NetworkAdapters
Export-ModuleMember Watch-DefaultGatewayChangeVpn
Export-ModuleMember chefdk

# Wintellect
Export-ModuleMember Compare-Directories
Export-ModuleMember Get-Hash
Export-ModuleMember Remove-IntelliTraceFile
Export-ModuleMember Test-PathReg
