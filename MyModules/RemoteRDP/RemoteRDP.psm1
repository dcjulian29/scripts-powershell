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
