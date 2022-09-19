$Script:dnsCache = @{
    "127.0.0.1" = "localhost"
}

function int64toIP([int64]$int) {
  (([math]::truncate($int / 16777216)).tostring() + "." `
    + ([math]::truncate(($int % 16777216) / 65536)).tostring() + "." `
    + ([math]::truncate(($int % 65536) / 256)).tostring() + "." `
    + ([math]::truncate($int % 256)).tostring() )
}

function iptoInt64 ($ip) {
  $octets = $ip.split(".")
  [int64]([int64]$octets[0] * 16777216 `
    + [int64]$octets[1] * 65536 `
    + [int64]$octets[2] * 256 `
    + [int64]$octets[3])
}

function netFirewall {
    [OutputType([System.String])]
    param (
        [String]$Name,
        [ValidateSet("add","del","show")]
        [String]$Operation,
        [String]$Protocol,
        [String]$LocalPort,
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,
        [ValidateSet("Allow", "Block", "Bypass")]
        [String]$Action
    )

    $argumentList = @('advfirewall', 'firewall', $Operation, 'rule', "name=""${Name}""")

    if ($Direction) {
        $dir = switch ($Direction) {
            "Inbound" { "in" }
            "Outbound" { "out" }
        }

        $argumentList += "dir=$dir"
    }

    if ($Protocol) {
        $argumentList += "protocol=$Protocol"
    }

    if ($LocalPort) {
        $argumentList += "localport=$LocalPort"
    }

    if ($Action) {
        $argumentList += "action=$Action"
    }

    $outputPath = "${env:TEMP}\netsh.out"

    $process = Start-Process netsh -ArgumentList $argumentList -Wait -NoNewWindow -RedirectStandardOutput $outputPath -Passthru

    if ($process.ExitCode -ne 0) {
        throw "Error Performing Operation '$Operation' For Firewall Rule"
    }

    return ((Get-Content $outputPath) -join "`n")
}

function netUrlAcl {
    [OutputType([System.String])]
    param (
        [String]$Protocol = "http",
        [ValidateSet("add","del","show")]
        [String]$Operation,
        [String]$Url,
        [String]$User
    )

    $argumentList = @($Protocol, $Operation, 'urlacl', "url=""${Url}""")

    if ($user) {
        $argumentList += "user=""${User}"""
    }

    $outputPath = "${env:TEMP}\netsh.out"

    $process = Start-Process netsh -ArgumentList $argumentList `
        -Wait -NoNewWindow -RedirectStandardOutput $outputPath -Passthru

    if ($process.ExitCode -ne 0) {
        throw "Error Performing Operation '${Operation}' For Reserved URL"
    }

    return ((Get-Content $outputPath) -join "`n")
}

function toBinary ($dottedDecimal) {
  $binary = ""
  $dottedDecimal.split(".") | ForEach-Object {
    $binary += $([Convert]::ToString($_, 2).padleft(8, "0"))
  }

  return $binary
}

function toDottedDecimal($binary) {
  $dottedDecimal = ""
  $i = 0

  do {
    $dottedDecimal += "." + [string]$([convert]::toInt32($binary.substring($i,8),2))
    $i += 8
  } while ($i -le 24)

 return $dottedDecimal.substring(1)
}

function getUrl {
    param (
        [String]$Protocol = "http",
        [String]$Hostname = "*",
        [String]$Port
    )

    return "${Protocol}://${Hostname}:${Port}/"
}

#------------------------------------------------------------------------------


function Get-IPv4NetworkClass {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Address
  )

  switch ($Address.Split('.')[0]) {
    { $_ -in 0..127 } { 'A' }
    { $_ -in 128..191 } { 'B' }
    { $_ -in 192..223 } { 'C' }
    { $_ -in 224..239 } { 'D' }
    { $_ -in 240..255 } { 'E' }
  }
}

function Get-IPv4NetworkEndAddress {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string] $Address
  )

  $mask = ($Address -Split '/')[1]
  $ip = toBinary ($Address -Split '/')[0]

  return [System.Net.IPAddress](toDottedDecimal $($ip.Substring(0, $mask).PadRight(31, "1") + "0"))
}

Set-Alias -Name "ipv4-end" -Value Get-IPv4NetworkEndAddress

function Get-IPv4NetworkStartAddress {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string] $Address
  )

  $mask = ($Address -Split '/')[1]
  $ip = ($Address -Split '/')[0]

  return [System.Net.IPAddress](toDottedDecimal $($ip.Substring(0,$mask).PadRight(31,"0") + "1"))
}

Set-Alias -Name "ipv4-start" -Value Get-IPv4NetworkStartAddress

function Get-IPv4Subnet {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Address,
    [ValidateRange(0, 32)]
    [Alias('CIDR')]
    [int] $MaskBits
  )

  if ($PSBoundParameters.ContainsKey('MaskBits')) {
    $mask = $MaskBits
  }

  if ($Address -match '/\d') {
    $Mask = ($Address -Split '/')[1]
    $Address = ($Address -Split '/')[0]
  }

  $class = Get-IPv4NetworkClass -Address $Address

  if ($Mask -notin 0..32) {
    $mask = switch ($Class) {
      'A' { 8 }
      'B' { 16 }
      'C' { 24 }
      default {
        throw "Subnet mask size was not specified and could not be inferred because the address is Class $Class."
      }
    }

    Write-Warning "Subnet mask size was not specified. Using default subnet size for a Class $Class network of /$Mask."
  }

  $ip = [System.Net.IPAddress]::Parse($Address)
  $subnet = [System.Net.IPAddress]::Parse((int64toIP ([Convert]::ToInt64(("1" * $Mask + "0" * (32 - $Mask)), 2))))
  $network = [System.Net.IPAddress]($subnet.Address -band $ip.Address)
  $broadcast = `
    [System.Net.IPAddress](toDottedDecimal $((toBinary $ip.IPAddressToString).Substring(0, $Mask).PadRight(32, "1")))

  $start = (iptoInt64 -ip $network.IPAddressToString) + 1
  $end = (iptoInt64 -ip $broadcast.IPAddressToString) - 1

  Write-Progress "Calcualting host addresses for $network/$Mask.."

  $addresses = for ($i = $start; $i -le $end; $i++) {
    int64toIP -int $i
  }

  return [PSCustomObject]@{
      IPAddress        = $ip
      Mask             = $Mask
      NetworkAddress   = $network
      BroadcastAddress = $broadcast
      SubnetMask       = $subnet
      Range            = "$network ~ $broadcast"
      HostAddresses    = $addresses
      HostAddressCount = (($end - $start) + 1)
  }
}

Set-Alias -Name "ipv4-subnet" -Value Get-IPv4Subnet

function Get-NetworkEstablishedConnection {
    [CmdletBinding()]
    param (
        [switch] $NoResolve
    )

    $r = @()

    Get-NetTCPConnection -State Established | ForEach-Object {
        if ($NoResolve) {
            $remoteName = $null
        } else {
            if (-not ($dnsCache.ContainsKey($_.RemoteAddress))) {
                $dnsCache.Add($_.RemoteAddress, `
                    $(Resolve-DnsName $_.RemoteAddress -ErrorAction SilentlyContinue))
            }

            $remoteName = $dnsCache[$_.RemoteAddress]
        }

        $process = Get-Process | Where-Object Id -eq $_.OwningProcess

        $r += [PSCustomObject]@{
            RemoteDNS   = $remoteName.Server
            RemoteIP    = $_.RemoteAddress
            RemotePort  = $_.RemotePort
            ProcessID   = $_.OwningProcess
            ProcessName = $process.ProcessName
            LocalIP     = $_.LocalAddress
            LocalPort   = $_.LocalPort
        }
    }

    return $r
}

function Get-NetworkInterface {
    [CmdletBinding()]
    param (
        [string] $InterfaceName,
        [string] $InterfaceType,
        [string] $InterfaceStatus
    )

    $i = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

    if ($InterfaceName) {
        $i = $i | Where-Object Name -eq $InterfaceName
    }

   if ($InterfaceType) {
        $i = $i | Where-Object NetworkInterfaceType -eq $InterfaceType
    }

    if ($InterfaceStatus) {
        $i = $i | Where-Object OperationalStatus -eq $InterfaceStatus
    }

    return $i
}

function Get-NetworkIP {
    [CmdletBinding()]
    param (
        [string] $InterfaceName,
        [string] $InterfaceType,
        [string] $InterfaceStatus
    )

    $collection = Get-NetworkInterface -InterfaceName $InterfaceName `
        -InterfaceType $InterfaceType -InterfaceStatus $InterfaceStatus


    $r = @()

    foreach ($item in $collection) {
        $r += [PSCustomObject] @{
            Name = $item.Name
            IPv4 = ($item.GetIPProperties().UnicastAddresses `
                | Where-Object PrefixLength -eq 24 ).Address.IPAddressToString
            IPv6 = ($item.GetIPProperties().UnicastAddresses `
                | Where-Object PrefixLength -eq 64 ).Address.IPAddressToString
        }
    }

    return $r
}

function Get-NetworkListeningPorts {
    $r = @()

    Get-NetTCPConnection -State Listen | ForEach-Object {
        $process = Get-Process | Where-Object Id -eq $_.OwningProcess

        $r += [PSCustomObject]@{
            LocalIP     = $_.LocalAddress
            LocalPort   = $_.LocalPort
            ProcessID   = $_.OwningProcess
            ProcessName = $process.ProcessName
        }
    }

    return $r
}

function Get-PrimaryIP {
    param(
      [switch]$IPv6
    )

    if ($IPv6) {
      return (Get-NetIPAddress -InterfaceIndex $((Get-NetRoute -AddressFamily IPv6 `
        | Where-Object { $_.DestinationPrefix -eq "::/0" }).ifIndex) `
            -AddressFamily IPv6 -PrefixOrigin "Manual").IPAddress
    } else {
      return (Get-NetIPAddress -InterfaceIndex $((Get-WmiObject -Class Win32_IP4RouteTable `
        | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
        | Sort-Object metric1).InterfaceIndex) -AddressFamily IPv4).IPAddress
    }
}

function Get-PrimaryMask {
  param(
    [switch]$IPv6
  )

  if ($IPv6) {
    return (Get-NetIPAddress -InterfaceIndex $((Get-NetRoute -AddressFamily IPv6 `
      | Where-Object { $_.DestinationPrefix -eq "::/0" }).ifIndex) `
          -AddressFamily IPv6 -PrefixOrigin "Manual").PrefixLength
  } else {
    return (Get-NetIPAddress -InterfaceIndex $((Get-WmiObject -Class Win32_IP4RouteTable `
      | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
      | Sort-Object metric1).InterfaceIndex) -AddressFamily IPv4).PrefixLength
  }
}

function Get-PrimarySubnet {
  $mask = Get-PrimaryMask
  return ([System.Net.IPAddress]::Parse( `
      (int64toIP ([Convert]::ToInt64(("1" * $mask + "0" * (32 - $mask)), 2))))).IPAddressToString
}

function Get-PublicIP {
  param(
    [Switch] $IPv6
  )

  if(-not $IPv6) {
    $url = 'ipv4bot.whatismyipaddress.com'
  } else {
    $url = 'ipv6bot.whatismyipaddress.com'
  }

  Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive `
    | Select-Object -ExpandProperty Content
}

function Invoke-Http {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=1)]
        [string] $Url,
        [Parameter(Mandatory=$True,Position=2)]
        [ValidateSet("GET", "POST", "HEAD")]
        [string] $Verb,
        [Parameter(Mandatory=$False,Position=3)]
        [string] $Content
    )

    $webRequest = [System.Net.WebRequest]::Create($url)
    $encodedContent = [System.Text.Encoding]::UTF8.GetBytes($content)
    $webRequest.Method = $verb.ToUpperInvariant()

    if ($encodedContent.length -gt 0) {
        $webRequest.ContentLength = $encodedContent.length
        $requestStream = $webRequest.GetRequestStream()
        $requestStream.Write($encodedContent, 0, $encodedContent.length)
        $requestStream.Close()
    }

    [System.Net.WebResponse] $resp = $webRequest.GetResponse();

    if ($resp -ne $null) {
        $rs = $resp.GetResponseStream();
        [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
        [string] $results = $sr.ReadToEnd();

        return $results
    }
}

function New-FirewallRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [String]$Protocol,
        [String]$LocalPort,
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,
        [ValidateSet("Allow", "Block", "Bypass")]
        [String]$Action
    )

    netFirewall -Name $Name `
        -Operation "add" `
        -Protocol $Protocol `
        -LocalPort $LocalPort `
        -Direction $Direction `
        -Action $Action
}

function New-UrlReservation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Port,
        [ValidateNotNullOrEmpty()]
        [String]$User
    )

    $url = getUrl $Protocol $Hostname $Port

    netUrlAcl -Protocol $Protocol -Operation "add" -Url $url -User $User
}

function Ping-Host {
  [CmdletBinding()]
  param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Address,
    [ValidateRange(100,50000)]
    [int] $Timeout = 2000
  )

  begin {
    $Online = @{
      Name = 'Online'
      Expression = { $_.Status -eq 'Success' }
    }

    $ping = New-Object System.Net.NetworkInformation.Ping
  }

  process {
    $Address | ForEach-Object { `
      $ping.Send($_, $Timeout) `
        | Select-Object -Property $Online, Status, Address, RoundtripTime `
        | Add-Member -MemberType NoteProperty -Name Name -Value $_ -PassThru
    }
  }
}

function Remove-FirewallRule {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )

    netFirewall -Name $Name -Operation "del"
}

function Remove-UrlReservation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Port
    )

    $url = getUrl $Protocol $Hostname $Port

    netUrlAcl -Protocol $Protocol -Operation "del" -Url $url
}

function Search-Network {
  param (
    [string]$Address = "$(Get-PrimaryIP)/$(Get-PrimaryMask)",
    [int]$TimeOut = 500,
    [int]$Attempts = 1,
    [switch]$NoResolve
  )

  $network = Get-IPv4Subnet $Address
  $i = 0
  $offline = $true
  $results = @()
  $counter = 0

  if ($network.HostAddressCount -lt 1) {
    return $null
  }

  foreach ($target in $network.HostAddresses) {
    do {
      Write-Progress -Activity "Searching Network:" `
      -Status "Pinging '$target'..." `
      -PercentComplete (($counter / $network.HostAddressCount) * 100)

      $status = Ping-Host -Address $target -TimeOut $TimeOut

      if ($status.Online) {
        $offline = $false

        if ($NoResolve) {
          $remoteName = $null
        } else {
            if (-not ($dnsCache.ContainsKey($target))) {
                $dnsCache.Add($target, `
                    $(Resolve-DnsName $target -NoHostsFile -NetbiosFallback -ErrorAction SilentlyContinue))
            }

            $remoteName = $dnsCache[$target].NameHost

            if (($remoteName.GetType()).BaseType -eq "System.Array") {
              $remoteName = $remoteName[0]
            }
        }

        $results += [PSCustomObject]@{
          Address    = $target
          ResponseTime = $status.RoundtripTime
          MAC   = $((Get-NetNeighbor -IPAddress $target -ErrorAcction SilentlyContinue).LinkLayerAddress -replace '-', ':')
          Name     = $remoteName
        }
      } else {
        $offline = $true
      }

      $i++
    } while (($i -le $Attempts) -and ($offline))

    $counter++
  }

  return $results
}

Set-Alias -Name "scan-network" -Value Search-Network

function Show-UrlReservation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$Port,
        [ValidateNotNullOrEmpty()]
        [String]$User
    )

    $url = getUrl $Protocol $Hostname $Port

    netUrlAcl -Operation "show" -Url $url -User $User
}

function Test-IpAddress {
  [CmdletBinding(DefaultParameterSetName = "any")]
  param (
    [parameter(ParameterSetName = "any", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [parameter(ParameterSetName = "v4", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [parameter(ParameterSetName = "v6", Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [string] $Address,
    [parameter(ParameterSetName = "v4")]
    [switch] $IPv4,
    [parameter(ParameterSetName = "v6")]
    [switch] $IPv6
  )

  $regex = ""
  $v4 = "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
  $v6 = "([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4}$|((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4})"

  switch ($PSCmdlet.ParameterSetName) {
    "v4" { $regex = $v4 }
    "v6" { $regex = $v6  }
    Default { $regex = "$v4|$v6" }
  }

  if ($Address -Match $regex) {
    return $true
  } else {
    return $false
  }
}

function Test-PrivateIPv4 {
  [CmdletBinding()]
  param(
    [parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [string] $Address
  )

  if ($Address -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
        return $true
  } else {
    return $false
  }
}

function Test-Url {
  <#
  .SYNOPSIS
  Takes a list of urls and verifies that the url is valid.

  .DESCRIPTION
  The Check-Url script takes a piped list of url and attempts download the HEAD of the file from the web. If it retrieves an HTTP status of OK then the URL is reported as valid. If the result is anything else or an exception, then the url is reported as invalid.

  .INPUTS
  List of url's to check. Note: the url's must begin with http:// or https://

  .OUTPUTS
  Returns a powershell object with two properties
    1. IsValid [bool] - signifies weather the url was determined as Valid or not
    2. Url [string] - the url that was checked.
    3. HttpStatus - The http status resulting from the web request.
    4. Error - Any possible error resulting from the request.

  .EXAMPLE
  @('http://www.google.com', 'http://www.asd----fDSAWQSDF-GZz.com') | .\Check-Url.ps1

  .EXAMPLE
  @('http://www.google.com', 'http://www.asd----fDSAWQSDF-GZz.com') | .\Check-Url.ps1 | where { !$_.IsValid }
  Reports the Invalid url's.
  #>

  BEGIN {}

  PROCESS {
    if ($_) {
      $url = $_;
      $urlIsValid = $false

      try {
        $request = [System.Net.WebRequest]::Create($url)
          $request.Method = 'HEAD'
          $response = $request.GetResponse()
          $httpStatus = $response.StatusCode
          $urlIsValid = ($httpStatus -eq 'OK')
          $tryError = $null
          $response.Close()
        } catch [System.Exception] {
          $httpStatus = $null
          $tryError = $_.Exception
          $urlIsValid = $false;
        }

        $x = New-Object Object | `
          Add-Member -MemberType NoteProperty -Name IsValid -Value $urlIsvalid -PassThru | `
          Add-Member -MemberType NoteProperty -Name Url -Value $_ -PassThru | `
          Add-Member -MemberType NoteProperty -Name HttpStatus -Value $httpStatus -PassThru | `
          Add-Member -MemberType NoteProperty -Name Error -Value $tryError -PassThru

          $x
    }
  }

  END {}
}
