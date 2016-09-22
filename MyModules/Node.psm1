$script:node = Find-ProgramFiles 'nodejs\node.exe'
$script:npm = "$(Split-Path $script:node)\node_modules\npm\bin\npm-cli.js"

Function Get-NodeVersion {
    Start-Node -p -e "process.versions.node + ' (' + process.arch + ')'"    
}

Function Start-NodePackageManager {
    Start-Node $script:npm $args;
}

Function Start-Node {
    if (Test-Node) {
        & $script:node $args
    } else {
        Write-Error "NodeJS is not installed!"
    }
}

Function Test-Node {
    Test-Path $script:node
}

###############################################################################

Export-ModuleMember Get-NodeVersion
Export-ModuleMember Start-NodePackageManager
Export-ModuleMember Start-Node
Export-ModuleMember Test-Node

Set-Alias npm Start-NodePackageManager
Set-Alias node Start-Node

Export-ModuleMember -Alias npm
Export-ModuleMember -Alias node
