@{
    ModuleVersion = '2112.17.1'
    GUID = '907bef0d-cf0d-47de-a77b-282e48ce85b1'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Ansible.psm1'
    NestedModules = @(
      "AnsibleInventory.psm1"
      "AnsibleLint.psm1"
      "AnsiblePlaybook.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
      "Confirm-AnsiblePlaybookSyntax"
      "Get-AnsibleConfig"
      "Get-AnsibleConfigDump"
      "Get-AnsibleConfigFile"
      "Get-AnsibleInventoryGraph"
      "Get-AnsibleInventoryAsJson"
      "Get-AnsibleInventoryAsToml"
      "Get-AnsibleInventoryAsYaml"
      "Get-AnsibleLintRules"
      "Get-AnsibleLintTags"
      "Get-AnsiblePlaybookHosts"
      "Get-AnsiblePlaybookTags"
      "Get-AnsiblePlaybookTasks"
      "Invoke-Ansible"
      "Invoke-AnsibleConfig"
      "Invoke-AnsibleContainer"
      "Invoke-AnsibleDoc"
      "Invoke-AnsibleGalaxy"
      "Invoke-AnsibleInventory"
      "Invoke-AnsibleLint"
      "Invoke-AnsibleLintPlaybook"
      "Invoke-AnsibleLintRole"
      "Invoke-AnsiblePlaybook"
      "Invoke-AnsibleVault"
      "Show-AnsibleFacts"
      "Show-AnsibleVariables"
      "Test-AnsiblePlaybookSyntax"
      "Protect-AnsibleVariable"
    )
    AliasesToExport = @(
      "ansible"
      "ansible-config"
      "ansible-doc"
      "ansible-encrypt"
      "ansible-facts"
      "ansible-galaxy"
      "ansible-inventory"
      "ansible-lint"
      "ansible-lint-playbook"
      "ansible-lint-role"
      "ansible-playbook"
      "ansible-playbook-hosts"
      "ansible-playbook-syntaxcheck"
      "ansible-playbook-tags"
      "ansible-playbook-tasks"
      "ansible-playbook-test"
      "ansible-variables"
      "ansible-vars"
      "ansible-vault"
      "Check-AnsiblePlaybookSyntax"
      "Validate-AnsiblePlaybookSyntax"
    )
}
