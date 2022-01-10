function findMachine {
    param (
        [string]$Name
    )

    $machine = $null

    try {
        $machine = $(getVbox).FindMachine($Name)
    } catch {}

    return $machine
}

function getVbox {
    return New-Object -ComObject "VirtualBox.VirtualBox"
}

function stateAsNumber {
    param (
        [string]$State
    )

    switch ($State) {
        "Stopped"                { return  1 }
        "Saved"                  { return  2 }
        "Teleported"             { return  3 }
        "Aborted"                { return  4 }
        "Running"                { return  5 }
        "Paused"                 { return  6 }
        "Stuck"                  { return  7 }
        "Snapshotting"           { return  8 }
        "Starting"               { return  9 }
        "Stopping"               { return 10 }
        "Restoring"              { return 11 }
        "TeleportingPausedVM"    { return 12 }
        "TeleportingIn"          { return 13 }
        "FaultTolerantSync"      { return 14 }
        "DeletingSnapshotOnline" { return 15 }
        "DeletingSnapshot"       { return 16 }
        "SettingUp"              { return 17 }
    }
}

function stateAsText {
    param (
        [int]$State
    )

    switch ($State) {
         1 { return "Stopped" }
         2 { return "Saved" }
         3 { return "Teleported" }
         4 { return "Aborted" }
         5 { return "Running" }
         6 { return "Paused" }
         7 { return "Stuck" }
         8 { return "Snapshotting" }
         9 { return "Starting" }
        10 { return "Stopping" }
        11 { return "Restoring" }
        12 { return "TeleportingPausedVM" }
        13 { return "TeleportingIn" }
        14 { return "FaultTolerantSync" }
        15 { return "DeletingSnapshotOnline" }
        16 { return "DeletingSnapshot" }
        17 { return "SettingUp" }

        default { return $State }
    }
}

#------------------------------------------------------------------------------

function Get-VirtualBoxMachine {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [Parameter(Position=0, ParameterSetName="Named")]
        [string[]]$Name,
        [Parameter(ParameterSetName="All")]
        [switch]$All,
        [Parameter(ParameterSetName="All")]
        [ValidateSet("Stopped","Running","Saved","Teleported","Aborted",
            "Paused","Stuck","Snapshotting","Starting","Stopping",
            "Restoring","TeleportingPausedVM","TeleportingIn","FaultTolerantSync",
            "DeletingSnapshotOnline","DeletingSnapshot","SettingUp")]
        [string]$State = "Running"
    )

    $vbox = getVbox
    $machines = @()
    $virtuals = @()

    if ($PSCmdlet.ParameterSetName -eq "Named") {
        foreach ($machine in $Name) {
            $vm = findMachine($machine)

            if ($vm) {
                $machines += $vm
            } else {
                Write-Warning "Could not find a registered machine named '$machine'. Names are Case Sensitive."
            }
        }
    } else {
        if ($All) {
            $machines = $vbox.Machines
        } else {
            $machines = $vbox.Machines | Where-Object { $_.State -eq $(stateAsNumber($State)) }
        }
    }

    if ($machines) {
        foreach ($machine in $machines) {
            $virtuals += New-Object -TypeName PSObject -Property @{
                Name = $machine.name
                State = $(stateAsText($machine.State))
                Description = $machine.description
                ID = $machine.ID
                OS = $machine.OSTypeID
                CPU = $machine.CPUCount
                MemoryMB = $machine.MemorySize
            }
        }
    }

    return $virtuals
}

Set-Alias -Name Get-VBoxMachine -Value Get-VirtualBoxMachine
Set-Alias -Name gvbm -Value Get-VirtualBoxMachine

function Find-VirtualBox {
    $vbox = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
        -Name "VBOX_MSI_INSTALL_PATH").VBOX_MSI_INSTALL_PATH + "VBoxManage.exe"

    if (-not (Test-Path $vbox)) {
        $vbox = $null
    }

    return $vbox
}

function Invoke-VirtualBox {
    & (Find-VirtualBox) $args
}

Set-Alias -Name "vbox" -Value Invoke-VirtualBox

function Start-VirtualBoxMachine {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
                   ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [Alias("Id")]
        [string[]]$Name,
        [switch]$Headless
    )

    begin { }

    process {
        foreach ($item in $Name) {
            $machine = findMachine($item)

            if ($machine) {
                Write-Output "Starting $($machine.Name)..."
                if ($PScmdlet.ShouldProcess($machine.Name)) {
                    if ($machine.State -lt 5) {
                        $session = New-Object -ComObject "VirtualBox.Session"
                        if ($Headless) {
                            $progress = $machine.LaunchVMProcess($session, "headless", [string[]]@())
                        } else {
                            $progress = $machine.LaunchVMProcess($session, "gui", [string[]]@())
                        }

                        while ($progress.Completed -eq 0) {
                            Start-Sleep -Seconds 1
                        }
                    } else {
                        Write-Warning "Cannot start '$($machine.Name)' since it is already running."
                    }
                }
            } else {
                Write-Warning "Failed to find virtual machine '$Name'"
            }
        }
    }

    end { }
}

Set-Alias -Name Start-VBoxMachine -Value Start-VirtualBoxMachine
Set-Alias -Name Resume-VirtualBoxMachine -Value Start-VirtualBoxMachine
Set-Alias -Name Resume-VBoxMachine -Value Start-VirtualBoxMachine

function Stop-VirtualBoxMachine {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
                   ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [Alias("Id")]
        [string[]]$Name
    )

    begin { }

    process {
        foreach ($item in $Name) {
            $machine = findMachine($item)

            if ($machine) {
                Write-Output "Stopping $($machine.Name)..."
                if ($PScmdlet.ShouldProcess($machine.Name)) {
                    if ($machine.State -eq 5) {
                        $session = New-Object -ComObject "VirtualBox.Session"
                        $machine.LockMachine($session, 1)
                        $session.Console.PowerButton()
                    } else {
                        Write-Warning "Cannot stop '$($machine.Name)' since it is not running."
                    }
                }
            } else {
                Write-Warning "Failed to find virtual machine '$Name'"
            }
        }
    }

    end { }
}

Set-Alias -Name Stop-VBoxMachine -Value Stop-VirtualBoxMachine

function Suspend-VirtualBoxMachine {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
                   ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [Alias("Id")]
        [string[]]$Name
    )

    begin { }

    process {
        foreach ($item in $Name) {
            $machine = findMachine($item)

            if ($machine) {
                Write-Output "Suspending $($machine.Name)..."
                if ($PScmdlet.ShouldProcess($machine.Name)) {
                    if (($machine.State -eq 4) -or ($machine.State -eq 5)) {
                        $session = New-Object -ComObject "VirtualBox.Session"
                        $machine.LockMachine($session, 1)
                        $progress = $session.Machine.SaveState()

                        while ($progress.Completed -eq 0) {
                            Start-Sleep -Seconds 1
                        }

                    } else {
                        Write-Warning "Cannot save the execution state. '$($machine.Name)' is not running."
                    }
                }
            } else {
                Write-Warning "Failed to find virtual machine '$Name'"
            }
        }
    }

    end { }
}

Set-Alias -Name Suspend-VBoxMachine -Value Suspend-VirtualBoxMachine
Set-Alias -Name Pause-VirtualBoxMachine -Value Suspend-VirtualBoxMachine
Set-Alias -Name Pause-VBoxMachine -Value Suspend-VirtualBoxMachine
