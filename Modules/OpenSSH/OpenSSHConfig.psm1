function Get-OpenSSHConfig {
  begin {
    $hostTable = New-Object System.Data.DataTable("SshHosts")

    "Host", "HostName", "User", "Port", "IdentityFile" | ForEach-Object {
      $column = New-Object System.Data.DataColumn $_
      $hostTable.Columns.Add($column)
    }

    $hostTable.Columns[3].DataType = [System.Type]::GetType("System.Int32")
    $content = Get-Content -Path $(Get-OpenSSHConfigFileName)
  }

  process {
    if  ($content.Length -eq 0) {
      return $null
    }

    foreach ($line in $content) {
      if ($line -match '\s*#.*') {
        continue
      }

      if ($line -match '^[Hh]ost\s+([^\s]+)') {
        if ($row) {
          $hostTable.Rows.Add($row)
        }

        $row = $hostTable.NewRow();
        $row["Host"] = $Matches[1]
      }

      if ($line -match '^\s*[^#]\s*[Hh]ost[Nn]ame\s+(\S+).*') {
        $row["HostName"] = $Matches[1]
      }


      if ($line -match '^\s*[^#]\s*[Us]ser\s+(\S+).*') {
        $row["User"] = $Matches[1]
      }

      if ($line -match '^\s*[^#]\s*[Pp]ort\s+(\S+).*') {
        $row["Port"] = $Matches[1]
      }

      if ($line -match '^\s*[^#]\s*[Ii]dentity[Ff]ile\s+(\S+).*') {
        $row["IdentityFile"] = $Matches[1]
      }
    }

    if ($row) {
      $hostTable.Rows.Add($row)
    }

    $default = $hostTable | Where-Object { $_.Host -eq "*" }

    foreach ($item in $hostTable) {
      if ($item.User.GetType().Name -eq "DBNull") {
        if ($default -and $default.User.GetType().Name -ne "DBNull") {
          $item.User = $default.User
        } else {
          $item.User = $env:USERNAME
        }
      }

      if ($item.Port.GetType().Name -eq "DBNull") {
        if ($default -and $default.Port.GetType().Name -ne "DBNull") {
          $item.Port = $default.Port
        } else {
          $item.Port = 22
        }
      }

      if ($item.IdentityFile.GetType().Name -eq "DBNull") {
        if ($default -and $default.IdentityFile.GetType().Name -ne "DBNull") {
          $item.IdentityFile = $default.IdentityFile
        } else {
          $item.IdentityFile = ""
        }
      }
    }
  }

  end {
    return $hostTable
  }
}

function Get-OpenSSHConfigFileName {
  if (Test-Path ${env:SystemDrive}\etc\ssh\config) {
    return "${env:SystemDrive}\etc\ssh\config"
  }

  return "${env:USERPROFILE}\.ssh\config"
}
