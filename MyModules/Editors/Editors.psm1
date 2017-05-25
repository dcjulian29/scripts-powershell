$script:VIM = Find-ProgramFiles 'vim\vim80\vim.exe'
$script:GVIM = Find-ProgramFiles 'vim\vim80\gvim.exe'
$script:NOTEPAD = Find-ProgramFiles 'Notepad++\notepad++.exe'

Function Start-VIM {
    Start-Process -FilePath $VIM -ArgumentList $args -NoNewWindow -Wait
}

Function Start-GVIM {
    Start-Process -FilePath $VIM -ArgumentList $args
}

Function Start-Notepad {
    Start-Process -FilePath $NOTEPAD -ArgumentList $args
}

##############################################################################

Export-ModuleMember Start-VIM
Export-ModuleMember Start-GVIM
Export-ModuleMember Start-Notepad

Set-Alias vi Start-VIM
Export-ModuleMember -Alias vi

Set-Alias vim Start-VIM
Export-ModuleMember -Alias vim

Set-Alias vim Start-GVIM
Export-ModuleMember -Alias gvim

Set-Alias np Start-Notepad
Export-ModuleMember -Alias np

Set-Alias notepad Start-Notepad
Export-ModuleMember -Alias notepad
