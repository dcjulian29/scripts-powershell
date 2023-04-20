@{
    ModuleVersion = '2304.19.1'
    Description = "A collection of commands to interact with ansible (via a docker container if needed) running the control node instance. Allows a very similar workflow regardless of operating system."
    GUID = '907bef0d-cf0d-47de-a77b-282e48ce85b1'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RequiredModules = @(
      @{
        ModuleName = "PowerShellForDocker"
        ModuleVersion = "2212.29.1"
        GUID = "2cd0c771-ed8b-48bc-b6bc-be8540c915e4"
       }
    )
    RootModule = 'Ansible.psm1'
    NestedModules = @(
      "AnsibleBinaries.psm1"
      "AnsibleDevOps.psm1"
      "AnsibleInventory.psm1"
      "AnsibleLint.psm1"
      "AnsiblePlaybook.psm1"
      "AnsibleVault.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
      "Assert-AnsibleProvision"
      "Confirm-AnsiblePlaybookSyntax"
      "Edit-AnsibleVault"
      "Export-AnsibleFacts"
      "Find-AnsibleConfig"
      "Get-AnsibleConfig"
      "Get-AnsibleConfigDump"
      "Get-AnsibleConfigFile"
      "Get-AnsibleFacts"
      "Get-AnsibleHostVariables"
      "Get-AnsibleInventoryGraph"
      "Get-AnsibleInventoryAsJson"
      "Get-AnsibleInventoryAsToml"
      "Get-AnsibleInventoryAsYaml"
      "Get-AnsibleLintRules"
      "Get-AnsibleLintTags"
      "Get-AnsiblePlaybookHosts"
      "Get-AnsiblePlaybookTags"
      "Get-AnsiblePlaybookTasks"
      "Get-AnsibleVariables"
      "Import-AnsibleFacts"
      "Invoke-Ansible"
      "Invoke-AnsibleCommunity"
      "Invoke-AnsibleConfig"
      "Invoke-AnsibleConnection"
      "Invoke-AnsibleConsole"
      "Invoke-AnsibleContainer"
      "Invoke-AnsibleDoc"
      "Invoke-AnsibleGalaxy"
      "Invoke-AnsibleInventory"
      "Invoke-AnsibleLint"
      "Invoke-AnsibleLintPlaybook"
      "Invoke-AnsibleLintRole"
      "Invoke-AnsiblePlaybook"
      "Invoke-AnsiblePlayRaspi"
      "Invoke-AnsibleProvision"
      "Invoke-AnsiblePull"
      "Invoke-AnsibleTest"
      "Invoke-AnsibleVault"
      "Invoke-Molecule"
      "Invoke-YamlLint"
      "New-AnsibleRole"
      "Protect-AnsibleVariable"
      "Remove-AnsibleVaultPassword"
      "Set-AnsibleVaultPassword"
      "Show-AnsibleFacts"
      "Show-AnsibleVariables"
      "Show-AnsibleVault"
      "Test-AnsiblePlaybookSyntax"
      "Update-AnsibleHost"
      "Update-AnsibleProvision"
    )
    AliasesToExport = @(
      "ansible"
      "ansible-community"
      "ansible-config"
      "ansible-connection"
      "ansible-console"
      "ansible-container"
      "ansible-doc"
      "ansible-encrypt"
      "ansible-facts"
      "ansible-facts-load"
      "ansible-facts-save"
      "ansible-facts-show"
      "ansible-galaxy"
      "ansible-host-update"
      "ansible-inventory"
      "ansible-lint"
      "ansible-lint-playbook"
      "ansible-lint-role"
      "ansible-load-facts"
      "ansible-new-role"
      "ansible-playbook"
      "ansible-playbook-hosts"
      "ansible-playbook-syntaxcheck"
      "ansible-playbook-tags"
      "ansible-playbook-tasks"
      "ansible-provision-assert"
      "ansible-provision-check"
      "ansible-provision-server"
      "ansible-provision-update"
      "ansible-pull"
      "ansible-role-new"
      "ansible-save-facts"
      "ansible-show-facts"
      "ansible-show-hostvars"
      "ansible-show-vars"
      "ansible-test"
      "ansible-variables"
      "ansible-vars"
      "ansible-vault"
      "ansible-vault-edit"
      "ansible-vault-view"
      "Check-AnsiblePlaybookSyntax"
      "molecule"
      "Validate-AnsiblePlaybookSyntax"
      "yamllint"
    )
}
