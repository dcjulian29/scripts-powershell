Function Check-Elevation {
    Write-Verbose "Checking for elevation... "
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
        Write-Verbose "Not an administrator session!"
        Write-Error "This command requires elevation"
        "$false"
    } else {
        Write-Verbose "Yes, this is an elevated session."
        "$true"
    }
}

##############################################################################

Export-ModuleMember Check-Elevation
