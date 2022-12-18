function Add-OpenSSHKnownHost {
  param (
    [Parameter(Mandatory=$true)]
    [string] $RemoteHost,
    [Parameter(Mandatory=$true)]
    [string] $KeyType,
    [Parameter(Mandatory=$true)]
    [string] $HostKey
  )

  $content = Get-Content -Path "$env:USERPROFILE/.ssh/known_hosts"
  $content += "$RemoteHost $KeyType $HostKey"

  Set-Content -Path "$env:USERPROFILE/.ssh/known_hosts" -Value $content
}

Set-Alias -Name "ssh-knownhost-add" -Value Add-OpenSSHKnownHost

function Get-OpenSSHKnownHosts {
  begin {
    $hostTable = New-Object System.Data.DataTable("KnownHosts")

    "LineNumber","Host", "KeyType", "HostKey" | ForEach-Object {
      $column = New-Object System.Data.DataColumn $_
      $hostTable.Columns.Add($column)
    }

    $hostTable.Columns[1].DataType = [System.Type]::GetType("System.String[]")
    $count = 1
  }

  process {
    $content = Get-Content -Path "$env:USERPROFILE/.ssh/known_hosts"

    foreach ($line in $content) {
      $parts = $line.Split(' ')
      $row = $hostTable.NewRow();

      $row["LineNumber"] = $count
      $row["Host"] = $parts[0].Split(',')
      $row["KeyType"] = $parts[1]
      $row["HostKey"] = $parts[2]

      $hostTable.Rows.Add($row)
      $count++
    }
  }

  end {
    return $hostTable
  }
}

function New-OpenSSHHostShortcut {
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName,
    [string]$Path = "$ComputerName.lnk"
  )

  Set-FileShortCut -Path $Path.ToUpper() `
    -TargetPath "${env:WINDIR}\System32\OpenSSH\ssh.exe"  `
    -Arguments "-F ""${env:SystemDrive}\etc\ssh\config"" $($ComputerName.ToLower())" `
    -Description "Open SSH Console to $($ComputerName.ToUpper())" `
    -IconPath "${env:SystemRoot}\System32\SHELL32.dll,92" `
    -WorkingDirectory "${env:WINDIR}\System32\OpenSSH"
}

function New-OpenSSHKey {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias("Host", "RemoteHost")]
    [string] $ComputerName,
    [string] $User = "${env:USERNAME}"
  )

  & C:\Windows\System32\OpenSSH\ssh-keygen.exe -t ecdsa -b 521 -m PEM `
    -C "$User@$ComputerName" -N "" -f "${env:SystemDrive}/etc/ssh/$ComputerName.key"
}

function Remove-OpenSSHKnownHost {
  [CmdletBinding(DefaultParameterSetName = "Named")]
  param (
    [Parameter(Mandatory=$true, ParameterSetName = "Named", Position = 0)]
    [Alias("Host", "RemoteHost")]
    [string] $ComputerName,
    [Parameter(Mandatory=$true, ParameterSetName = "Numbered", Position = 0)]
    [Alias("Line")]
    [int] $LineNumber
  )

  $content = Get-Content -Path "$env:USERPROFILE/.ssh/known_hosts"
  $newContent = @()

  if ($PsCmdlet.ParameterSetName -eq "Named") {
    foreach ($line in $content) {
      if (-not ($line -imatch ".*$([Regex]::Escape($ComputerName)).*")) {
          $newContent += $line
      }
    }
  }

  if ($PsCmdlet.ParameterSetName -eq "Numbered") {
    $LineNumber--  # Index is 0 based but we say line 1 for that...

    for ($i = 0; $i -lt $content.Count; $i++) {
      if ($LineNumber -ne $i) {
        $newContent += $content[$i]
      }
    }
  }

  if ($content.Length -eq $newContent.Length) {
    if ($PsCmdlet.ParameterSetName -eq "Numbered") {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Line $($LineNumber + 1) was not found in your Known Hosts file." `
        -ExceptionType "System.Management.Automation.ItemNotFoundException" `
        -ErrorId "ItemNotFoundException" -ErrorCategory "ObjectNotFound"))
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$ComputerName' was not found in your Known Hosts file." `
        -ExceptionType "System.Management.Automation.ItemNotFoundException" `
        -ErrorId "ItemNotFoundException" -ErrorCategory "ObjectNotFound"))
    }
  } else {
    Set-Content -Path "$env:USERPROFILE/.ssh/known_hosts" -Value $newContent
  }
}

Set-Alias -Name ssh-knownhost-remove -Value Remove-OpenSSHKnownHost
