function Get-DockerImage {
  param (
    [string]$Name,
    [switch]$Unused
  )

  if ($Name) {
    $images = Invoke-Docker "images $Name --no-trunc"
  } else {
    if ($Unused) {
      Invoke-Docker "images 'dangling=true' --no-trunc"
    } else {
      $images = Invoke-Docker "images --no-trunc"
    }
  }

  $list = @()

  if ($images) {
    foreach ($line in $images) {
      if ($line.StartsWith("REPOSITORY")) {
        continue # Exclude Header Row
      }

      $result = $line | Select-String -Pattern '(\S+(?:(?!\s{2}).)+)' -AllMatches

      $image = New-Object -TypeName PSObject

      $id = $result.Matches[2].Value
      if ($id.IndexOf(':') -gt 0) {
        $id = $id.Substring($id.IndexOf(':') + 1)
      }

      $image | Add-Member -MemberType NoteProperty -Name Id -Value $id

      $image | Add-Member -MemberType NoteProperty -Name Name -Value $result.Matches[0].Value
      $image | Add-Member -MemberType NoteProperty -Name Tag -Value $result.Matches[1].Value
      $image | Add-Member -MemberType NoteProperty -Name Created -Value $result.Matches[3].Value

      $size = $result.Matches[4].Value
      $size = $size.ToUpper()
      $size -match '[A-Za-z]+' | Out-Null
      $size = [double]::Parse($size -replace '[^0-9.]')
      switch ($Matches[0]) {
        "KB" { $size = $size * 1KB }
        "MB" { $size = $size * 1MB }
        "GB" { $size = $size * 1GB }
        "TB" { $size = $size * 1TB }
      }

      $size = [int][Math]::Round($size, 0, [MidPointRounding]::AwayFromZero)

      $image | Add-Member -MemberType NoteProperty -Name Size -Value $size

      $list += $image
    }
  }

  return $list
}

Set-Alias -Name docker-image -Value Get-DockerImage

function Pop-DockerImage {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$Tag = "latest"
  )

  Invoke-Docker "pull ${Name}:$Tag"
}

Set-Alias -Name Pull-DockerImage -Value Pop-DockerImage
Set-Alias -Name docker-pull -Value Pop-DockerImage

function Remove-DockerImage {
  param (
    [string]$Id,
    [string]$Name,
    [switch]$Unused,
    [switch]$Force
  )

  if ($Id) {
    $images = (Get-DockerImage | Where-Object { $_.Id -eq $Id }).Id
  } else {
    if ($Name) {
      $images = (Get-DockerImage | Where-Object { $_.Id -eq $Id }).Id
    } else {
      if ($Unused) {
        $images = (Get-DockerImage -Unused).Id
      } else {
        $images = (Get-DockerImage).Id
      }
    }
  }

  $images | ForEach-Object {
    if ($Force) {
      Invoke-Docker "rmi -f $_"
    } else {
      Invoke-Docker "rmi $_"
    }
  }
}
