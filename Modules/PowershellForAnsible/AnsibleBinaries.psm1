function executeCommand($command, $parameters) {
  Write-Verbose "~~> $command $parameters"

  $InPath = Get-Command $command -ErrorAction SilentlyContinue

  if ($null -ne $InPath) {
    if ($InPath.CommandType -eq "Application") {
    Write-Verbose "Executing native '$command'..."
    Start-Process -FilePath $command -ArgumentList $parameters -NoNewWindow -Wait

    return
  }

  Write-Verbose "Executing docker '$command'..."
  Invoke-AnsibleContainer -Command "$command $parameters"
  }
}

#-----------------------------------------------------------------------------

function Invoke-Ansible {
  [CmdletBinding()]
  [Alias("ansible")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible" $Parameters
}

function Invoke-AnsibleCommunity {
  [CmdletBinding()]
  [Alias("ansible-community")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-community" $Parameters
}

function Invoke-AnsibleConfig {
  [CmdletBinding()]
  [Alias("ansible-config")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-config" $Parameters
}

function Invoke-AnsibleConnection {
  [CmdletBinding()]
  [Alias("ansible-connection")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-connection" $Parameters
}

function Invoke-AnsibleConsole {
  [CmdletBinding()]
  [Alias("ansible-console")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-console" $Parameters
}

function Invoke-AnsibleDoc {
  [CmdletBinding()]
  [Alias("ansible-doc")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-doc" $Parameters
}

function Invoke-AnsibleGalaxy {
  [CmdletBinding()]
  [Alias("ansible-galaxy")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-galaxy" $Parameters
}

function Invoke-AnsibleInventory {
  [CmdletBinding()]
  [Alias("ansible-inventory")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-inventory" $Parameters
}

function Invoke-AnsibleLint {
  [CmdletBinding()]
  [Alias("ansible-lint")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-lint" $Parameters
}

function Invoke-AnsiblePlaybook {
  [CmdletBinding()]
  [Alias("ansible-playbook")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-playbook" $Parameters
}

function Invoke-AnsiblePull {
  [CmdletBinding()]
  [Alias("ansible-pull")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-pull" $Parameters
}

function Invoke-AnsibleTest {
  [CmdletBinding()]
  [Alias("ansible-test")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-test" $Parameters
}

function Invoke-AnsibleVault {
  [CmdletBinding()]
  [Alias("ansible-vault")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "ansible-vault" $Parameters
}

function Invoke-Molecule {
  [CmdletBinding()]
  [Alias("molecule")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "molecule" $Parameters
}

function Invoke-YamlLint {
  [CmdletBinding()]
  [Alias("yamllint")]
  param (
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string] $Parameters
  )

  executeCommand "yamllint" $Parameters
}
