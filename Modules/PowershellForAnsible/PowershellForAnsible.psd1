@{
    ModuleVersion = '2202.5.1'
    Description = "A collection of commands to interact with a docker container running the control node instance. Allows a very similar workflow as on a Linux system."
    GUID = '907bef0d-cf0d-47de-a77b-282e48ce85b1'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RequiredModules = @(
      @{
        ModuleName = "PowerShellForDocker"
        ModuleVersion = "2202.5.1"
       }
    )
    RootModule = 'PowershellForAnsible.psm1'
    NestedModules = @(
      "AnsibleDevOps.psm1"
      "AnsibleInventory.psm1"
      "AnsibleLint.psm1"
      "AnsiblePlaybook.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
      "Assert-AnsibleProvision"
      "Confirm-AnsiblePlaybookSyntax"
      "Edit-AnsibleVault"
      "Export-AnsibleFacts"
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
      "Invoke-Ansible"
      "Invoke-AnsibleConfig"
      "Invoke-AnsibleContainer"
      "Invoke-AnsibleDoc"
      "Invoke-AnsibleGalaxy"
      "Invoke-AnsibleHostCommand"
      "Invoke-AnsibleInventory"
      "Invoke-AnsibleLint"
      "Invoke-AnsibleLintPlaybook"
      "Invoke-AnsibleLintRole"
      "Invoke-AnsiblePlayBase"
      "Invoke-AnsiblePlaybook"
      "Invoke-AnsiblePlayDev"
      "Invoke-AnsiblePlayTest"
      "Invoke-AnsibleProvision"
      "Invoke-AnsibleVault"
      "New-AnsibleRole"
      "Ping-AnsibleHost"
      "Protect-AnsibleVariable"
      "Remove-AnsibleVagrantHosts"
      "Reset-AnsibleEnvironmentDev"
      "Reset-AnsibleEnvironmentTest"
      "Show-AnsibleFacts"
      "Show-AnsibleVariables"
      "Show-AnsibleVault"
      "Test-AnsiblePlaybookSyntax"
      "Test-AnsibleProvision"
      "Update-AnsibleHost"
      "Update-AnsibleProvision"
    )
    AliasesToExport = @(
      "ansible"
      "ansible-config"
      "ansible-container"
      "ansible-dev-reset"
      "ansible-dev-play"
      "ansible-doc"
      "ansible-encrypt"
      "ansible-facts"
      "ansible-facts-save"
      "ansible-facts-show"
      "ansible-galaxy"
      "ansible-hosts-exec"
      "ansible-hosts-ping"
      "ansible-hosts-update"
      "ansible-inventory"
      "ansible-lint"
      "ansible-lint-playbook"
      "ansible-lint-role"
      "ansible-new-role"
      "ansible-playbook"
      "ansible-playbook-hosts"
      "ansible-playbook-syntaxcheck"
      "ansible-playbook-tags"
      "ansible-playbook-tasks"
      "ansible-playbook-test"
      "ansible-play-base"
      "ansible-play-dev"
      "ansible-play-test"
      "ansible-provision-check"
      "ansible-provision-server"
      "ansible-provision-test"
      "ansible-provision-update"
      "ansible-reset-dev"
      "ansible-reset-test"
      "ansible-role-new"
      "ansible-save-facts"
      "ansible-show-facts"
      "ansible-show-hostvars"
      "ansible-show-vars"
      "ansible-test-play"
      "ansible-test-reset"
      "ansible-variables"
      "ansible-vars"
      "ansible-vault"
      "ansible-vault-edit"
      "ansible-vault-view"
      "Check-AnsiblePlaybookSyntax"
      "Validate-AnsiblePlaybookSyntax"
      "destroy.sh"
      "new-role.sh"
      "ping-hosts.sh"
      "play-base.sh"
      "play-dev.sh"
      "provision-check.sh"
      "provision-server.sh"
      "provision-test.sh"
      "provision-update.sh"
      "reset-dev.sh"
      "reset-test.sh"
      "save-facts.sh"
      "show-facts.sh"
      "show-hostvars.sh"
      "show-vars.sh"
      "update-servers.sh"
      "vault-edit.sh"
      "vault-view.sh"
    )
}
