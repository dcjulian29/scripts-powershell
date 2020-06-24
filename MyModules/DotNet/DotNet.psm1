function Get-AllAssemblyInfo {
    Get-ChildItem `
        | Where-Object { $_.Extension -eq ".dll" } `
        | ForEach-Object { Get-AssemblyInfo $_ }
}

Set-Alias aia Get-AllAssemblyInfo

function Get-AssemblyInfo {
    param (
        $Assembly = $(throw "An assembly name is required.")
    )


    if (Test-Path $Assembly) {
        $loaded = [System.Reflection.Assembly]::LoadFrom($(Get-Item $Assembly))
    } else {
        # Load from GAC
        $loaded = [System.Reflection.Assembly]::LoadWithPartialName("$Assembly")
    }

    "{0} [{1}]" -f $loaded.GetName().name, $loaded.GetName().version
}

function Get-NetFramework
{
    param (
        [string] $ComputerName = $env:COMPUTERNAME
    )

    $versions = @(
        "2.0"
        "3.0"
        "3.5"
        "4.0"
        "4.5"
        "4.5.1"
        "4.5.2"
        "4.6"
        "4.6.1"
        "4.6.2"
        "4.7"
        "4.7.1"
        "4.7.2"
        "4.8"
    )

    $installed = @()

    foreach ($version in $versions) {
        if (Test-NetFramework -Version $version -ComputerName $ComputerName) {
            $installed += $version
        }
    }

    return $installed -join ','
}

function Get-RemoteNetFramework {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $ComputerName
    )

    begin {
        $counter = 1
        $total = $ComputerName.Length
        $list = @()
        $originalProgressPreference = $Global:ProgressPreference
    }

    process {
        foreach ($computer in $ComputerName) {
            $Global:ProgressPreference = $originalProgressPreference

            Write-Progress -Activity "Get Remote .Net Versions" `
                -Status "Querying Frameworks installed on $computer" `
                -PercentComplete (($counter / $total) * 100)

            $Global:ProgressPreference = 'SilentlyContinue'

            $net2 = ""
            $net30 = ""
            $net35 = ""
            $net4 = ""
            $winrm = ""
            $online = Test-NetConnection -ComputerName $computer `
                -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            $remoteAddress = $online.RemoteAddress

            if ($online.PingSucceeded) {
                $winrm = "Blocked"
                $check = Test-NetConnection -ComputerName $computer -Port 5985 `
                    -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

                if ($check.TcpTestSucceeded) {
                    $winrm = "Allowed"

                    if (Invoke-Command -ComputerName $computer { ipconfig } 2> $null) {
                        $versions = Get-NetFramework -ComputerName $computer

                        if ($versions -like "*2.0*") {
                            $net2 = "2.0"
                        }

                        if ($versions -like "*3.0*") {
                            $net30 = "3.0"
                        }

                        if ($versions -like "*3.5*") {
                            $net35 = "3.5"
                        }

                        if ($versions -like "*4.*") {
                            $net4 = $versions.Substring($versions.IndexOf('4'))
                        }
                    } else {
                        $winrm = "Allowed, but Failed"
                    }
                }
            }

            $detail = New-Object PSObject

            $detail | Add-Member -Type NoteProperty -Name 'Computer' -Value $computer
            $detail | Add-Member -Type NoteProperty -Name 'RemoteAddress' -Value $remoteAddress
            $detail | Add-Member -Type NoteProperty -Name 'Online' -Value $online.PingSucceeded
            $detail | Add-Member -Type NoteProperty -Name 'PSRemoting' -Value $winrm
            $detail | Add-Member -Type NoteProperty -Name 'Net2' -Value $net2
            $detail | Add-Member -Type NoteProperty -Name 'Net30' -Value $net30
            $detail | Add-Member -Type NoteProperty -Name 'Net35' -Value $net35
            $detail | Add-Member -Type NoteProperty -Name 'Net4' -Value $net4

            $list += $detail

            $counter++
        }
    }

    end {
        $Global:ProgressPreference = $originalProgressPreference
        return $list
    }
}

function Test-NetFramework
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Version,
        [string] $ComputerName = $env:COMPUTERNAME
    )

    $major = [int]$version.Split('.')[0]
    $path = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP'

    switch -Regex ($major) {
        '2|3' {
            switch ($version) {
                "2.0" { $path = "$path\v2.0.50727" }
                "3.0" { $path = "$path\v3.0" }
                "3.5" { $path = "$path\v3.5" }
                default { return $false }
            }

            $check = [Scriptblock]::Create("Get-ItemProperty `"$path`" -Name Install -ErrorAction SilentlyContinue")

            if ($ComputerName -eq $env:COMPUTERNAME) {
                $installed = Get-ItemProperty $path -Name Install -ErrorAction SilentlyContinue
            } else {
                $installed = Invoke-Command -ComputerName $ComputerName -ScriptBlock $check
            }

            if ($installed) {
                return $true
            }

            return $false
        }

        '4' {
            $path = "$path\v4\Full"
            switch ($version) {
                "4.5"   { $release = "378389 378675 378758" }
                "4.5.1" { $release = "378675 378758" }
                "4.5.2" { $release = "379893" }
                "4.6"   { $release = "393295 393297" }
                "4.6.1" { $release = "394254 394271" }
                "4.6.2" { $release = "394802 394806" }
                "4.7"   { $release = "460798 460805" }
                "4.7.1" { $release = "461308 461310" }
                "4.7.2" { $release = "461808 461814" }
                "4.8"   { $release = "528040 528209 528049" }
                default { return $false }
            }

            $check = [Scriptblock]::Create("Get-ItemProperty `"$path`" -Name Release -ErrorAction SilentlyContinue")

            if ($ComputerName -eq $env:COMPUTERNAME) {
                $installed = (Get-ItemProperty $path -Name Release -ErrorAction SilentlyContinue).Release
            } else {
                $installed = (Invoke-Command -ComputerName $ComputerName -ScriptBlock $check).Release
            }

            if ($release.Contains($installed)) {
                return $true
            }

            return $false

        }

        default {
            return $false
        }
    }
}

function Test-NetFramework2 { Test-NetFramework -Version "2.0" }

function Test-NetFramework3 { Test-NetFramework -Version "3.0" }

function Test-NetFramework35 { Test-NetFramework -Version "3.5" }

function Test-NetFramework40 { Test-NetFramework -Version "4.0" }

function Test-NetFramework45 { Test-NetFramework -Version "4.5" }

function Test-NetFramework451 { Test-NetFramework -Version "4.5.1" }

function Test-NetFramework452 { Test-NetFramework -Version "4.5.2" }

function Test-NetFramework46 { Test-NetFramework -Version "4.6" }

function Test-NetFramework461 { Test-NetFramework -Version "4.6.1" }

function Test-NetFramework462 { Test-NetFramework -Version "4.6.2" }

function Test-NetFramework47 { Test-NetFramework -Version "4.7" }

function Test-NetFramework471 { Test-NetFramework -Version "4.7.1" }

function Test-NetFramework472 { Test-NetFramework -Version "4.7.2" }

function Test-NetFramework48 { Test-NetFramework -Version "4.8" }
