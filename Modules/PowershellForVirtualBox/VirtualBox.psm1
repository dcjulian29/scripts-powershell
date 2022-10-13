function apiVersion {
  return $(getVbox).apiVersion
}

function findMachine($Name) {
  $machine = $null
  try { $machine = $(getVbox).FindMachine($Name) } catch {}
  return $machine
}

function getSession {
  return New-Object -ComObject "VirtualBox.Session"
}

function getVbox {
  return New-Object -ComObject "VirtualBox.VirtualBox"
}

function stateAsNumber($State) {
  switch ($State) {
    "Stopped"                { return  1 }
    "PoweredOff"             { return  1 }
    "Saved"                  { return  2 }
    "Teleported"             { return  3 }
    "Aborted"                { return  4 }
    "AbortedSaved"           { return  5 }
    "Running"                { return  6 }
    "Paused"                 { return  7 }
    "Stuck"                  { return  8 }
    "Teleporting"            { return  9 }
    "LiveSnapshotting"       { return 10 }
    "Starting"               { return 11 }
    "Stopping"               { return 12 }
    "Saving"                 { return 13 }
    "Restoring"              { return 14 }
    "FaultTolerantSync"      { return 14 }
    "TeleportingPausedVM"    { return 15 }
    "TeleportingIn"          { return 16 }
    "DeletingSnapshotOnline" { return 17 }
    "DeletingSnapshotPaused" { return 18 }
    "OnlineSnapshotting"     { return 19 }
    "RestoringSnapshot"      { return 20 }
    "DeletingSnapshot"       { return 21 }
    "SettingUp"              { return 22 }
    "Snapshotting"           { return 23 }
    "FirstOnline"            { return  6 }
    "LastOnline"             { return 19 }
    "FirstTransient"         { return  9 }
    "LastTransient"          { return 23 }
  }
}

function stateAsText($State) {
  switch ($State) {
     1 { return "PoweredOff" }
     2 { return "Saved" }
     3 { return "Teleported" }
     4 { return "Aborted" }
     5 { return "AbortedSaved" }
     6 { return "Running" }
     7 { return "Paused" }
     8 { return "Stuck" }
     9 { return "Teleporting" }
    10 { return "LiveSnapshotting" }
    11 { return "Starting" }
    12 { return "Stopping" }
    13 { return "Saving" }
    14 { return "Restoring" }
    15 { return "TeleportingPausedVM" }
    16 { return "TeleportingIn" }
    17 { return "DeletingSnapshotOnline" }
    18 { return "DeletingSnapshotPaused" }
    19 { return "OnlineSnapshotting"}
    20 { return "RestoringSnapshot" }
    21 { return "DeletingSnapshot" }
    22 { return "SettingUp" }
    23 { return "Snapshotting" }
  }
}

#------------------------------------------------------------------------------

function Get-VirtualBoxMachine {
  [CmdletBinding()]
  [Alias("Get-VBoxMachine","gvbm")]
  param(
    [Parameter(Position=0)]
    [string[]] $Name,
    [ValidateSet("Stopped", "Running", "Saved", "Teleported", "Aborted",
      "Paused", "Stuck", "Snapshotting", "Starting", "Stopping",
      "Restoring", "TeleportingPausedVM", "TeleportingIn", "FaultTolerantSync",
      "DeletingSnapshotOnline", "DeletingSnapshot", "SettingUp")]
    [Parameter(Position=1)]
    [string] $State
  )

  $machines = $(getVbox).Machines
  $virtuals = @()

  if ($State.Length -gt 0) {
    $machines = $machines | Where-Object { $_.State -eq $(stateAsNumber($State)) }
  }

  if ($Name.Count -gt 0) {
    $machines = $machines | Where-Object { $_.Name -in $Name }
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

  $machines = $null

  return $virtuals
}

function Get-VirtualBoxProcess {
  [CmdletBinding()]
  param ()

  Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.path -match "oracle\\virt" }
}

function Find-VirtualBox {
    $vb = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
        -Name "VBOX_MSI_INSTALL_PATH").VBOX_MSI_INSTALL_PATH + "VBoxManage.exe"

    if (-not (Test-Path $vb)) {
        $vb = $null
    }

    return $vb
}

function Invoke-VirtualBox {
  [CmdletBinding()]
  [Alias("vbox")]
  param ()

    & (Find-VirtualBox) $args
}


function Start-VirtualBoxMachine {
  [CmdletBinding(SupportsShouldProcess = $True)]
  [Alias("Start-VBoxMachine", "Resume-VirtualBoxMachine", "Resume-VBoxMachine")]
  param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
               ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [Alias("Id")]
    [string[]]$Name,
    [switch]$Headless
  )

  foreach ($item in $Name) {
    $machine = findMachine($item)
    $permittedStates = @(
      stateAsNumber "PoweredOff"
      stateAsNumber "AbortedSaved"
      stateAsNumber "Saved"
      stateAsNumber "Paused"
    )

    if ($machine) {
      Write-Verbose "Starting $($machine.Name)..."
      if ($PScmdlet.ShouldProcess($machine.Name)) {
        if ($machine.State -in $permittedStates) {
          if ($Headless) {
            $progress = $machine.LaunchVMProcess($(getSession), "headless", [string[]]@())
          } else {
            $progress = $machine.LaunchVMProcess($(getSession), "gui", [string[]]@())
          }

          while ($progress.Completed -eq 0) {
            Start-Sleep -Seconds 1
          }
        } else {
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Cannot start '$($machine.Name)', current state: '$(stateAsText $machine.State)'" `
            -ExceptionType "System.InvalidOperationException" `
            -ErrorId "System.InvalidOperation" `
            -ErrorCategory "InvalidOperation"))
        }
      }
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Failed to find virtual machine named '$Name'. Names are case sensitive." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" `
        -ErrorCategory "InvalidOperation"))
    }
  }
}

function Stop-VirtualBoxMachine {
  [CmdletBinding(SupportsShouldProcess = $True)]
  [Alias("Stop-VBoxMachine")]
  param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
                ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [Alias("Id")]
    [string[]]$Name
  )

  foreach ($item in $Name) {
    $machine = findMachine($item)
    $permittedStates = @(
      stateAsNumber "Running"
      stateAsNumber "Paused"
      stateAsNumber "Stuck"
    )

    if ($machine) {
      Write-Verbose "Stopping $($machine.Name)..."
      if ($PScmdlet.ShouldProcess($machine.Name)) {
        if ($machine.State -in $permittedStates) {
          $session = getSession
          $machine.LockMachine($session, 1)
          $session.Console.PowerButton()
        } else {
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Cannot stop '$($machine.Name)', current state: '$(stateAsText $machine.State)'" `
            -ExceptionType "System.InvalidOperationException" `
            -ErrorId "System.InvalidOperation" `
            -ErrorCategory "InvalidOperation"))
        }
      }
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Failed to find virtual machine named '$Name'. Names are case sensitive." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" `
        -ErrorCategory "InvalidOperation"))
    }
  }
}

function Suspend-VirtualBoxMachine {
  [CmdletBinding(SupportsShouldProcess = $True)]
  [Alias("Suspend-VBoxMachine", "Pause-VirtualBoxMachine", "Pause-VBoxMachine")]
  param (
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a virtual machine name",
               ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullorEmpty()]
    [Alias("Id")]
    [string[]]$Name
  )

  foreach ($item in $Name) {
    $machine = findMachine($item)
    $permittedStates = @(
      stateAsNumber "Runing"
    )

    if ($machine) {
      Write-Verbose "Suspending $($machine.Name)..."
      if ($PScmdlet.ShouldProcess($machine.Name)) {
        if ($machine.State -in $permittedStates) {
          $session = getSession
          $machine.LockMachine($session, 1)
          $progress = $session.Machine.Pause()

          while ($progress.Completed -eq 0) {
            Start-Sleep -Seconds 1
          }
        } else {
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Cannot save the execution state of '$($machine.Name)', current state: '$(stateAsText $machine.State)'" `
            -ExceptionType "System.InvalidOperationException" `
            -ErrorId "System.InvalidOperation" `
            -ErrorCategory "InvalidOperation"))
        }
      }
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Failed to find virtual machine named '$Name'. Names are case sensitive." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" `
        -ErrorCategory "InvalidOperation"))
    }
  }
}
