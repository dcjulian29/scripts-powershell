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
Export-ModuleMember Get-Share
Export-ModuleMember Get-SubNetItems
Export-ModuleMember New-Share
Export-ModuleMember Set-GUI
Export-ModuleMember Test-Port
Export-ModuleMember Compare-OPML
Export-ModuleMember Enable-RemoteDesktop
Export-ModuleMember Find-NoRssPostInMonths
Export-ModuleMember Pin-Taskbar
Export-ModuleMember Reset-NetworkAdapters
Export-ModuleMember Watch-DefaultGatewayChangeVpn
