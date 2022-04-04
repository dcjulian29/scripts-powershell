$script:scp = "$env:windir\System32\OpenSSH\scp.exe"
$script:ssh = "$env:windir\System32\OpenSSH\ssh.exe"
$script:etc = "$env:SystemDrive\etc\ssh"

function generateScpArguments($IdentityFile,$Recurse,$Port,$LocalPath,$RemoteUser,$RemoteHost,$RemotePath,$Direction) {
    $arguments = getConfigFile

    if ($IdentifyFile) {
        $arguments += " -i ""$IdentityFile"""
    } else {
        $arguments += " -i ""$(getIdentityFile $null $RemoteHost)"""
    }

    if ($Recurse) {
        $arguments += " -r"
    }

    if ($Port) {
        $arguments += " -P $Port"
    }

    if ($RemoteUser) {
        $RemoteHost = "$RemoteUser@$RemoteHost"
    }

    if ($Direction -eq 'Up') {
        $arguments += " $LocalPath $($RemoteHost):$RemotePath"
    } else {
        $arguments += " $($RemoteHost):$RemotePath $LocalPath"
    }

    return $arguments
}

function getConfigFile {
    if (Test-Path "$etc\config") {
        return "-F ""$etc\config"""
    }
}

function getIdentityFile($IdentityFile,$RemoteHost) {
    if (($null -eq $IdentityFile) -and (Test-Path "$etc\$RemoteHost.key")) {
        $IdentityFile = "$etc\$RemoteHost.key"
    }

    return $IdentityFile
}

#------------------------------------------------------------------------------

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
    $line = "$RemoteHost $KeyType $HostKey"
    $content += $line

    Set-Content -Path "$env:USERPROFILE/.ssh/known_hosts" -Value $content
}

function Get-OpenSSHKnownHosts {
    begin {
        $hostTable = New-Object System.Data.DataTable("KnownHosts")

        "Host", "KeyType", "HostKey" | ForEach-Object {
            $column = New-Object System.Data.DataColumn $_
            $hostTable.Columns.Add($column)
        }

        $hostTable.Columns[0].DataType = [System.Type]::GetType("System.String[]")
    }

    process {
        $content = Get-Content -Path "$env:USERPROFILE/.ssh/known_hosts"

        foreach ($line in $content) {
            $parts = $line.Split(' ')
            $row = $hostTable.NewRow();

            $row["Host"] = $parts[0].Split(',')
            $row["KeyType"] = $parts[1]
            $row["HostKey"] = $parts[2]

            $hostTable.Rows.Add($row)
        }
    }

    end {
        return $hostTable
    }
}

function Invoke-OpenSCP {
    $arguments = "$(getConfigFile) $args"

    Write-Verbose "[SCP Arguments] $arguments"
    $oldTitle = $host.UI.RawUI.WindowTitle
    Start-Process -FilePath $scp -ArgumentList $arguments -NoNewWindow -Wait
    $host.UI.RawUI.WindowTitle = $oldTitle
}

Set-Alias scp Invoke-OpenSCP

function Invoke-OpenSSH {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Remote", "RemoteHost")]
        [string]$ComputerName,
        [string]$IdentityFile,
        [string]$Command,
        [string]$User,
        [Alias("NoSave", "Transient", "NoHostChecking")]
        [switch]$Temporary
    )

    if ($ComputerName.Contains("@")) {
        if ($User) {
            Write-Error "Cannot specify an explicit user and also one in computer connection string. Ignoring that one."
        } else {
            $User = $ComputerName.Split('@')[0]
        }

        $ComputerName = $ComputerName.Split('@')[1]
    }

    $arguments = getConfigFile

    $IdentityFile = getIdentityFile $IdentityFile $RemoteHost
    if ($IdentityFile -and (Test-Path $IdentityFile)) {
        $arguments = $arguments + " -i ""$IdentityFile"""
    }

    if ($Temporary) {
        $arguments = $arguments + " -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    }

    if ($User) {
        $arguments = $arguments + " $User@$ComputerName"
    } else {
        $arguments = $arguments + " $ComputerName"
    }

    if ($Command) {
        $arguments = $arguments + " -t `"$Command`""
    }

    Write-Verbose "[SSH Arguments] $arguments"
    $oldTitle = $host.UI.RawUI.WindowTitle
    Start-Process -FilePath $ssh -ArgumentList $arguments -NoNewWindow -Wait
    $host.UI.RawUI.WindowTitle = $oldTitle
}

Set-Alias ssh Invoke-OpenSSH
Set-Alias sshell Invoke-OpenSSH

function Invoke-OpenSSHCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [string]$IdentityFile
    )

    Invoke-OpenSSH -ComputerName $ComputerName -IdentityFile $IdentityFile -Command $Command
}

Set-Alias Execute-OpenSSHCommand Invoke-OpenSSHCommand
Set-Alias sshellc Invoke-OpenSSHCommand

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
    [Alias("ComputerName")]
    [string] $Host,
    [string] $User = "${env:USERNAME}",
    [switch] $CopyToRemote
  )

  $file = "`"$etc\$Host.key`""

  & C:\Windows\System32\OpenSSH\ssh-keygen.exe -t ecdsa -b 521 -m PEM -C `"$User@$Host`" -N `"`" -f $file

  if ($CopyToRemote) {
    Send-FileScp -LocalPath $file -RemotePath "~/.ssh/authorized_keys" `
      -RemoteHost $Host -RemoteUser $User
  }
}

function Receive-FileScp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalPath,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$RemotePath,
        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,
        [string]$RemoteUser,
        [string]$IdentityFile,
        [int32]$Port,
        [switch]$Recurse
    )

    $arguments = generateScpArguments $IdentityFile $Recurse.IsPresent $Port `
        $LocalPath $RemoteUser $RemoteHost $RemotePath "Down"

    Write-Verbose "[SCP Recieve Arguments] $arguments"
    Invoke-OpenSCP $arguments
}

function Remove-OpenSSHKnownHost {
    param (
        [Parameter(Mandatory=$true)]
        [string] $RemoteHost
    )

    $content = Get-Content -Path "$env:USERPROFILE/.ssh/known_hosts"
    $newContent = @()
    foreach ($line in $content) {
        if (-not ($line -imatch ".*$([Regex]::Escape($RemoteHost)).*")) {
            $newContent += $line
        }
    }

    if ($content.Length -eq $newContent.Length) {
        Write-Warning "$RemoteHost was not found in Known Hosts file."
    } else {
        Set-Content -Path "$env:USERPROFILE/.ssh/known_hosts" -Value $newContent
    }
}

function Send-FileScp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalPath,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$RemotePath,
        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,
        [string]$RemoteUser,
        [string]$IdentityFile,
        [int32]$Port,
        [switch]$Recurse
    )

    $arguments = generateScpArguments $IdentityFile $Recurse.IsPresent $Port `
        $LocalPath $RemoteUser $RemoteHost $RemotePath "Up"

    Write-Verbose "[SCP Send Arguments] $arguments"
    Invoke-OpenSCP $arguments
}
