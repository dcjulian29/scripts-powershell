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

function getUrl {
    param (
        [String]$Protocol = "http",
        [String]$Hostname = "*",
        [String]$Port
    )

    return "${Protocol}://${Hostname}:${Port}/"
}

#------------------------------------------------------------------------------

function Get-NetworkIP {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string] $Interface
  )

  $collection = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

  if ($Interface) {
    $collection = $collection | Where-Object Name -eq $Interface
  }

  $r = @()

  foreach ($item in $collection) {
    $r += [PSCustomObject] @{
      Alias = $item.Name
      IPv4 = ($item.GetIPProperties().UnicastAddresses `
        | Where-Object PrefixLength -eq 24 ).Address.IPAddressToString
      IPv6 = ($item.GetIPProperties().UnicastAddresses `
        | Where-Object PrefixLength -eq 64 ).Address.IPAddressToString
    }
  }

  return $r
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

function New-NetFirewallRule {
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

function Remove-NetFirewallRule {
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
