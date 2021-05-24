function disableRdpFile($computers) {
    if ($computers) {
        $computers = $computers | Where-Object { $_.Status -eq "Unreachable" }

        foreach ($computer in $computers) {
            Move-Item -Path $computer.File -Destination "$($computer.File).disabled"
        }
    }
}
function Get-ActiveRdpSession {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]] $ComputerName = $env:COMPUTERNAME
    )

    Get-RdpSession $ComputerName "Active"
}

function Get-DisconnectedRdpSession {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]] $ComputerName = $env:COMPUTERNAME
    )

    Get-RdpSession $ComputerName "Disc"
}

function Get-RdpSession {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("Active", "Disc")]
        [string] $State
    )

    begin {
        $sessionTable = New-Object System.Data.DataTable("RdpSessions")

        "ComputerName", "UserName", "ID", "State" | ForEach-Object {
            $column = New-Object System.Data.DataColumn $_
            $sessionTable.Columns.Add($column)
        }

        $counter = 1
        $total = $ComputerName.Length
    }

    process {
        foreach ($computer in $ComputerName) {
            Write-Progress -Activity "Get RDP Sessions" `
                -Status "Querying RDP Sessions on $computer" `
                -PercentComplete (($counter / $total) * 100)

            if (Test-Connection -ComputerName $computer -Quiet -Count 1) {
                $results = (cmd /c "query.exe session /server:$computer 2> nul") -split "`n"
                foreach ($line in $results) {
                    if ($state) {
                        $regex = $state
                    } else {
                        $regex = "Disc|Active"
                    }

                    if (($line -NotMatch "services|console") -and ($line -match $regex)) {
                        $session = $($line -replace ' {2,}',',').Split(',')
                        $row = $sessionTable.NewRow();

                        $row["ComputerName"] = $computer
                        $row["UserName"] = $session[1]
                        $row["ID"] = $session[2]
                        $row["State"] = $session[3]

                        $sessionTable.Rows.Add($row)
                    }
                }
            }

            $counter++
        }
    }

    end {
        return $sessionTable
    }
}

Set-Alias -Name rdplist -Value Get-RdpSession

function Close-RdpSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string] $ComputerName,
        [Parameter(Mandatory = $true, Position = 1)]
        [string] $SessionID
    )

    $scriptBlock = [Scriptblock]::Create("logoff $SessionID /V")
    Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock
}

Set-Alias -Name rdpkick -Value Close-RdpSession

function Disable-RdpHostFile {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path,
        [string] $ExcludeFilter
    )

    if ($ExcludeFilter) {
        $computers = Find-RdpHostFile -Path $Path -ExcludeFilter $ExcludeFilter
    } else {
        $computers = Find-RdpHostFile -Path $Path
    }

    disableRdpFile($computers)
}

function Disable-RdpHostFileDirectory {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path = "$env:SystemDrive\etc\rdp",
        [string] $ExcludeFilter
    )

    $files = (Get-ChildItem -Path $(Resolve-Path $Path) -Filter "*.rdp" -Recurse).FullName

    if ($files) {
        if ($ExcludeFilter) {
            $computers = Find-RdpHostFile -Path $files -ExcludeFilter $ExcludeFilter
        } else {
            $computers = Find-RdpHostFile -Path $files
        }
    }

    disableRdpFile($computers)
}

function Find-RdpHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $ComputerName,
        [string] $ExcludeFilter
    )

    begin {
        $table = New-Object System.Data.DataTable("RdpHost")

        "ComputerName", "IPAddress", "Status" | ForEach-Object {
            $column = New-Object System.Data.DataColumn $_
            $table.Columns.Add($column)
        }

        $counter = 1
        $total = $ComputerName.Length
    }

    process {
        foreach ($computer in $ComputerName) {
            Write-Progress -Activity "Finding RDP Host Information" `
                -Status "Looking for $computer" `
                -PercentComplete (($counter / $total) * 100)

            $row = $table.NewRow();

            $row["ComputerName"] = $computer

            if (Test-Connection -ComputerName $computer -Quiet -Count 1) {
                $row["IPAddress"] = (Test-NetConnection -ComputerName $computer).RemoteAddress.IPAddressToString
                $row["Status"] = "Online"
            } else {
                $row["IPAddress"] = ""
                $row["Status"] = "Unreachable"
            }

            $table.Rows.Add($row)
            $counter++
        }
    }

    end {
        return $table
    }
}

Set-Alias -Name Validate-RdpHost -Value Find-RdpHost

function Find-RdpHostFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string[]] $Path,
        [string] $ExcludeFilter
    )

    begin {
        $table = New-Object System.Data.DataTable("RdpHost")

        "File", "ComputerName", "IPAddress", "UserName", "Status" | ForEach-Object {
            $column = New-Object System.Data.DataColumn $_
            $table.Columns.Add($column)
        }

        $counter = 1
        $total = $Path.Length
    }

    process {
        foreach ($file in $Path) {
            $file = Resolve-Path -Path $file

            Write-Progress -Activity "Finding RDP Host Information" `
                -Status "Looking for $file" `
                -PercentComplete (($counter / $total) * 100)

            $content = Get-Content $file

            $hostLine = $content -match '^full address:s:(.*)$'

            if (-not $hostLine) {
                continue
            }

            $hostAddress = $hostLine.Split(':')[2]

            if ($ExcludeFilter -and ($hostAddress -imatch $ExcludeFilter)) {
                continue
            }

            $row = $table.NewRow();

            $row["File"] = $file
            $row["ComputerName"] = $hostAddress

            $userLine = $content -match '^username:s:(.*)$'
            if ($userLine) {
                $row["UserName"] = $userLine.Split(':')[2]
            }

            if (Test-Connection -ComputerName $hostAddress -Quiet -Count 1) {
                $row["IPAddress"] = (Test-NetConnection -ComputerName $hostAddress).RemoteAddress.IPAddressToString
                $row["Status"] = "Online"
            } else {
                $row["IPAddress"] = ""
                $row["Status"] = "Unreachable"
            }

            $table.Rows.Add($row)
            $counter++
        }
    }

    end {
        return $table
    }
}

Set-Alias -Name Validate-RdpHostFile -Value Find-RdpHostFile

function Find-RdpHostFileDirectory {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path = "$env:SystemDrive\etc\rdp",
        [string] $ExcludeFilter
    )

    $files = (Get-ChildItem -Path $(Resolve-Path $Path) -Filter "*.rdp" -Recurse).FullName

    if ($files) {
        if ($ExcludeFilter) {
            Find-RdpHostFile -Path $files -ExcludeFilter $ExcludeFilter
        } else {
            Find-RdpHostFile -Path $files
        }
    }
}

Set-Alias -Name Validate-RdpHostFileDirectory -Value Find-RdpHostFileDirectory

function New-RemoteDesktopShortcut {
    param (
        [string]$Path = "$ComputerName.rdp",
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UserName = "${env:USERDOMAIN}\${env:USERNAME}"
    )

    if (Test-Path $Path) {
        $choice = Select-Item -Caption "RDP File Exists" `
            -Message "Do you want to replace the file?" `
            -choiceList "&Yes", "&No" -default 1

        if ($choice -eq 0) {
            Remove-Item $Path -Force -Confirm:$false
        }
    }

    Set-Content -Path $Path -Value @"
full address:s:$ComputerName
redirectprinters:i:0
redirectcomports:i:0
redirectsmartcards:i:0
redirectclipboard:i:1
redirectposdevices:i:0
username:s:$UserName
screen mode id:i:1
use multimon:i:0
desktopwidth:i:1366
desktopheight:i:768
winposstr:s:0,1,0,24,1390,937
session bpp:i:32
compression:i:1
"@
}

Set-Alias -Name New-RdpShortcut -Value New-RemoteDesktopShortcut

function Restore-RdpHostFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string[]] $Path,
        [string] $ExcludeFilter
    )

        $Path = Resolve-Path $Path
        foreach ($file in $Path) {
            if ($ExcludeFilter -and ($file -imatch $ExcludeFilter)) {
                continue
            }

            if ($file -like "*.rdp.disabled") {
               Move-Item -Path $file -Destination "$($file -replace '.disabled', '')"
            }
        }
}

function Restore-RdpHostFileDirectory {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path = "$env:SystemDrive\etc\rdp",
        [string] $ExcludeFilter
    )

    $files = (Get-ChildItem -Path $(Resolve-Path $Path) -Filter "*.rdp.disabled" -Recurse).FullName

    if ($files) {
        if ($ExcludeFilter) {
            Restore-RdpHostFile -Path $files -ExcludeFilter $ExcludeFilter
        } else {
            Restore-RdpHostFile -Path $files
        }
    }

}
