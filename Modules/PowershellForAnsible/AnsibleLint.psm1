function executeAnsibleLint {
  param (
    [string] $LintType,
    [string[]] $LintItem,
    [string] $RulesPath,
    [string[]] $SkipRule,
    [string[]] $WarnRule,
    [string] $ConfigFile,
    [string[]] $ExcludePath,
    [string[]] $Tag,
    [bool] $Parsable,
    [bool] $JsonOutput,
    [bool] $ShortOutput,
    [bool] $KeepDefaultRules,
    [bool] $NoColor
  )

  $params = "-f rich "

  if ($Parsable) {
    $params = "-f pep8 "

    if ($JsonOutput) {
      $params = "-f codeclimate "
    } elseif ($ShortOutput) {
      $params = "-f quiet "
    }
  } else {
      if ($JsonOutput) {
        $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
          -Message "JSON Output requires the -Parsable switch to be included!" `
          -ExceptionType "System.ArgumentException" `
          -ErrorId "AnsibleLintArgument" `
          -ErrorCategory "SyntaxError" `
          -TargetObject "JsonOutput"))
      }

      if ($ShortOutput) {
        $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
          -Message "Short Output requires the -Parsable switch to be included!" `
          -ExceptionType "System.ArgumentException" `
          -ErrorId "AnsibleLintArgument" -ErrorCategory "SyntaxError" `
          -TargetObject "ShortOutput"))
      }
  }

  if ($RulesPath.Length -gt 0) {
    $params += "-r $(Get-PathForContainer $RulesPath) "

    if ($KeepDefaultRules) {
        $params += "-R "
    }
  } else {
    if ($KeepDefaultRules) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Keep Default Rules is only used when also specifying a rule directory!" `
        -ExceptionType "System.ArgumentException" `
        -ErrorId "SyntaxError" -ErrorCategory "SyntaxError" `
        -TargetObject "KeepDefaultRules"))
    }
  }

  if ($Tag.Count -gt 0) {
    $params += "-t $($Tag -Join ',') "
  }

  if ($SkipRule.Count -gt 0) {
    $params += "-x $($SkipRule -Join ',') "
  }

  if ($WarnRule.Count -gt 0) {
    $params += "-w $($WarnRule -Join ',') "
  }

  if ("" -ne $ConfigFile) {
    $params += "- c '$(Get-FilePathForContainer -Path $ConfigFile)' "
  }

  if ($NoColor) {
    $params += "--nocolor "
  }

  if ($ExcludePath.Count -gt 0) {
    $params += "--exclude "
    foreach ($path in $ExcludePath) {
      $params += "'$(Get-PathForContainer -Path $path -MustBeChild)',"
    }

    $params = $params.Substring(0, $params.Length -1) + " "
  }

  if ($LintItem.Count -gt 0) {
    foreach ($item in $LintItem) {
      if ("role" -eq $LintType) {
        if (Test-Path "roles/$item") {
          $params += Get-PathForContainer -Path "roles/$item" -MustBeChild
        } else {
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Role does not exists!" `
            -ExceptionType "System.Management.Automation.ItemNotFoundException" `
            -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
        }
      }

      if ("playbook" -eq $LintType) {
        if (Test-Path "playbook/$item") {
          $params += Get-PathForContainer -Path "playbook/$item" -MustBeChild
        } else {
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Playbook does not exists!" `
            -ExceptionType "System.Management.Automation.ItemNotFoundException" `
            -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
        }
      }
    }
  }

  Write-Verbose $params
  Invoke-AnsibleLint $params.Trim()
}

#------------------------------------------------------------------------------

function Get-AnsibleLintRules {
  Invoke-AnsibleLint -L
}

function Get-AnsibleLintTags {
  Invoke-AnsibleLint -T
}

function Invoke-AnsibleLintRole {
  [CmdletBinding()]
  param (
      [string[]] $Role,
      [string] $RulesPath,
      [string[]] $SkipRule,
      [string[]] $WarnRule,
      [string] $ConfigFile,
      [string[]] $ExcludePath,
      [string[]] $Tag,
      [switch] $Parsable,
      [switch] $JsonOutput,
      [switch] $ShortOutput,
      [switch] $KeepDefaultRules,
      [switch] $NoColor
  )

  executeAnsibleLint -LintType "role" -LintItem $Role -RulesPath $RulesPath `
    -SkipRule $SkipRule -WarnRule $WarnRule -ConfigFile $ConfigFile `
    -ExcludePath $ExcludePath -Tag $Tag -Parsable:$Parsable.IsPresent `
    -JsonOutput:$JsonOutput.IsPresent -ShortOutput:$ShortOutput.IsPresent `
    -KeepDefaultRules:$KeepDefaultRules.IsPresent -NoColor:$NoColor.IsPresent
}

Set-Alias -Name ansible-lint-role -Value Invoke-AnsibleLintRole

function Invoke-AnsibleLintPlaybook {
  [CmdletBinding()]
  param (
      [string[]] $Playbook,
      [string] $RulesPath,
      [string[]] $SkipRule,
      [string[]] $WarnRule,
      [string] $ConfigFile,
      [string[]] $ExcludePath,
      [string[]] $Tag,
      [switch] $Parsable,
      [switch] $JsonOutput,
      [switch] $ShortOutput,
      [switch] $KeepDefaultRules,
      [switch] $NoColor
  )

  executeAnsibleLint -LintType "playbook" -LintItem $Playbook -RulesPath $RulesPath `
    -SkipRule $SkipRule -WarnRule $WarnRule -ConfigFile $ConfigFile `
    -ExcludePath $ExcludePath -Tag $Tag -Parsable:$Parsable.IsPresent `
    -JsonOutput:$JsonOutput.IsPresent -ShortOutput:$ShortOutput.IsPresent `
    -KeepDefaultRules:$KeepDefaultRules.IsPresent -NoColor:$NoColor.IsPresent
}

Set-Alias -Name ansible-lint-playbook -Value Invoke-AnsibleLintPlaybook
