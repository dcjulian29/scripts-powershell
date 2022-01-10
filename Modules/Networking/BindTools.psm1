function bindContainer {
  [CmdletBinding()]
  param (
    [string]$Command,
    [string]$Arguments,
    [string]$Additional
  )

  if (Test-DockerLinuxEngine) {
    $params = @{
      Image = "mbentley/bind-tools"
      Tag = "latest"
      Interactive = $true
      Name = "bind_shell"
      AdditionalArgs = $Additional
    }

    if ($Command) {
      $params.Add("Command", "`"$Command`"")
    }

    $params.GetEnumerator().ForEach({ Write-Verbose "$($_.Name)=$($_.Value)" })

    New-DockerContainer @params
  } else {
    Write-Error "Bind Tools sub-module requires the Linux Docker Engine!" -Category ResourceUnavailable
  }
}

#------------------------------------------------------------------------------

function Invoke-Dig {
  bindContainer -Command "dig" -Additional "$args"
}

Set-Alias -Name dig -Value Invoke-Dig
Set-Alias -Name bind-dig -Value Invoke-Dig

function Invoke-ArpaName {
  bindContainer -Command "arpaname" -Additional "$args"
}

Set-Alias -Name arpaname -Value Invoke-ArpaName
Set-Alias -Name bind-arpaname -Value Invoke-ArpaName

function Invoke-Host {
  bindContainer -Command "host" -Additional "$args"
}

Set-Alias -Name host -Value Invoke-Host
Set-Alias -Name bind-host -Value Invoke-Host

function Invoke-NSLookup {
  bindContainer -Command "nslookup" -Additional "$args"
}

Set-Alias -Name lookup -Value Invoke-NSLookup
Set-Alias -Name bind-nslookup -Value Invoke-NSLookup

function Invoke-NSUpdate {
  bindContainer -Command "nsupdate" -Additional "$args"
}

Set-Alias -Name nsupdate -Value Invoke-NSUpdate
Set-Alias -Name bind-nsupdate -Value Invoke-NSUpdate
