Function Get-Node {
    Find-ProgramFiles 'nodejs\node.exe'
}

Function Get-Npm {
    if (Test-Node) {
        "$(Split-Path $script:node)\node_modules\npm\bin\npm-cli.js"
    }
}

Function Get-NodeVersion {
    Start-Node -p -e "process.versions.node + ' (' + process.arch + ')'"    
}

Function Start-NodePackageManager {
    Start-Node Get-Npm $args;
}

Function Start-Node {
    if (Test-Node) {
        & Get-Node $args
    } else {
        Write-Error "NodeJS is not installed!"
    }
}

Function Test-Node {
    Test-Path Get-Node
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
