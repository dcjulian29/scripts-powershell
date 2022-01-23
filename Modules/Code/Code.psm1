function Import-DevelopmentPowerShellModule {
  [CmdletBinding(DefaultParameterSetName="Module")]
  param (
    [Parameter(Mandatory=$True, Position=0, ParameterSetName="Module")]
    [string[]]$Module,
    [Parameter(ParameterSetName="Module")]
    [Parameter(ParameterSetName="All")]
    [string]$Path = $(Get-DefaultCodeFolder),
    [Parameter(Mandatory=$True, ParameterSetName="All")]
    [switch]$All
  )

  if (-not (Test-Path $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$Path' was not found or available!" `
      -ExceptionType "System.IO.DirectoryNotFoundException" `
      -ErrorId "ResourceUnavailable" `
      -ErrorCategory "ResourceUnavailable" `
      -TargetObject 'Import-DevelopmentPowerShellModule'))
  }

  $moduleFolder = (Get-ChildItem -Path $Path -Filter "Modules" `
    -Recurse -ErrorAction SilentlyContinue).FullName

  if ($PSCmdlet.ParameterSetName -eq 'Module') {
    if (Test-Path "$moduleFolder\$Module\$Module.psd1") {
        $moduleFile = "$Module.psd1"
    } else {
        if (Test-Path "$moduleFolder\$Module\$Module.psm1") {
            $moduleFile = "$Module.psm1"
        }
    }

    if (Test-Path $moduleFile) {
      $removal = Get-Module  | Where-Object { $_.Name -eq $Module }

      do {
        if ($null -ne $removal) {
          Remove-Module -Name $removal -Force -Verbose:$false #$Verbose.IsPresent
        }

        $removal = Get-Module  | Where-Object { $_.Name -eq $Module }
      } until ($null -eq $removal)

      Import-Module -Global "$moduleFolder\$Module\$moduleFile" `
        -Verbose:($PSBoundParameters.ContainsKey('Verbose'))
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Module' was not found or available!" `
        -ExceptionType "System.IO.DirectoryNotFoundException" `
        -ErrorId "ResourceUnavailable" `
        -ErrorCategory "ResourceUnavailable" `
        -TargetObject $Module))
    }
  } else {
    $modules = (Get-ChildItem -Path $moduleFolder).Name

    foreach ($module in $modules) {
      if ($module -eq "GlobalScripts") {
        continue
      }

      Import-DevelopmentPowerShellModule -Module $module -Path $Path `
        -Verbose:($PSBoundParameters.ContainsKey('Verbose'))
    }
  }

  Get-Module -All | Select-Object Name, Version, Path | `
    Where-Object { $_.Path -like "$moduleFolder*"} | Format-Table
}

Set-Alias -Name idpsm -Value Import-DevelopmentPowerShellModule
