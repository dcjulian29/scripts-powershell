function Connect-WirelessProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("ProfileName")]
        [string] $Name
    )

    $profileName = Get-WirelessProfile $Name

    if (-not ($null -eq $profileName)) {
        if ($profileName.GetType().Name -eq 'String') {
            $interface = (netsh wlan show interfaces `
                | Select-String -Pattern "\s{4}Name\s{19}:\s(.*)" `
                | &{ process { [PSCustomObject]@{
                   Name = $_.matches[0].groups[1].value
                }}}).Name

            netsh wlan connect name=$profileName interface=$interface
        } else {
            Write-Warning $("Can only connect to one Wireless Profile at a time. " `
                + "'$Name' is not specific enough.")
        }
    } else {
        Write-Warning "Wireless profile '$Name' not found!"
    }
}

function Export-WirelessProfile {
    [CmdletBinding()]
    param (
        [Alias("ProfileName")]
        [string] $Name,
        [string] $Path = $((Get-Location).Path)
    )

    if ($Name) {
        netsh wlan export profile name="$Name" folder="$Path"
    } else {
        netsh wlan export profile folder="$Path"
    }
}

function Get-WirelessProfile {
    [CmdletBinding()]
    param (
        [Alias("ProfileName")]
        [string] $Name
    )

    $all = $(netsh wlan show profiles)
    $profiles = @()

    foreach ($line in $all) {
        if ($line -like "* : *") {
            $profiles += $line.split(":")[1].Trim()
        }
    }

    if ($Name) {
        $profiles = $profiles | Where-Object { $_ -like "*$Name*" }
    }

    return $profiles
}

function Import-WirelessProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path
    )

    $Path = Resolve-Path $Path

    netsh wlan add profile filename="$Path" user=all
}

function New-WirelessProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [string] $PresharedKey
    )

    $xml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
      <name>$Name</name>
      <SSIDConfig>
         <SSID>
              <name>$Name</name>
          </SSID>
     </SSIDConfig>
     <connectionType>ESS</connectionType>
     <connectionMode>auto</connectionMode>
     <MSM>
         <security>
             <authEncryption>
                 <authentication>WPA2PSK</authentication>
                 <encryption>AES</encryption>
                 <useOneX>false</useOneX>
             </authEncryption>

"@

    if ($PresharedKey) {
        $xml += @"
             <sharedKey>
                 <keyType>passPhrase</keyType>
                 <protected>false</protected>
                <keyMaterial>$PresharedKey</keyMaterial>
            </sharedKey>

"@
    }

    $xml += @"
        </security>
    </MSM>
    <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
        <enableRandomization>false</enableRandomization>
    </MacRandomization>
</WLANProfile>
"@

    $filename = [System.IO.Path]::GetTempFileName()

    Set-Content -Path $filename -Value $xml

    netsh wlan add profile filename="$filename"

    Remove-Item -Path $filename -Force
}

function Remove-WirelessProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("ProfileName")]
        [string] $Name
    )

    $p = Get-WirelessProfile $Name

    if ($p) {
        foreach ($item in $p) {
            netsh wlan delete profile $item
        }
    } else {
        Write-Warning "No wireless profile like '$Name' found!"
    }
}
