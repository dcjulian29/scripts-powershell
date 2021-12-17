function Get-AnsibleLintRules {
  Invoke-AnsibleLint -L
}

function Get-AnsibleLintTags {
  Invoke-AnsibleLint -T
}

function Invoke-AnsibleLint {
    Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-lint" -Command "$args"
}

Set-Alias -Name ansible-lint -Value Invoke-AnsibleLint
