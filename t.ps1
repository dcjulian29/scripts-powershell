Get-Content -Path "$PSScriptRoot\*" -Filter "*.psm1" | `
    Out-String | Invoke-Expression

###############################################################################

Function-To-Test
