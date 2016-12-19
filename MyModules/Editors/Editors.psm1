Function Start-VI {
    & vim.exe $args
}

Function Start-Notepad {
    & (Find-ProgramFiles 'Notepad++\notepad++.exe') $args
}

##############################################################################

Export-ModuleMember Start-VI
Export-ModuleMember Start-Notepad

Set-Alias vi Start-VI
Export-ModuleMember -Alias vi

Set-Alias np Start-Notepad
Export-ModuleMember -Alias np

