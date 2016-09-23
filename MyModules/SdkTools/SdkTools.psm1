$script:WindowsSdkPath = First-Path `
    ("$($env:SYSTEMDRIVE)\Program Files\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools") `
    ("$($env:SYSTEMDRIVE)\Program Files\Microsoft SDKs\Windows\v8.0A\bin\NETFX 4.0 Tools") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.0 Tools") `
    ("$($env:SYSTEMDRIVE)\Program Files\Microsoft SDKs\Windows\v7.0A\bin") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\bin") `
    ("$($env:SYSTEMDRIVE)\Program Files\Microsoft SDKs\Windows\v6.0A\bin") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft SDKs\Windows\v6.0A\bin")

function Check-WindowsSdk() {
    if (-not (Test-Path $script:WindowsSdkPath)) {
        throw "Windows SDK is not installed. Install it to run this command."
    }
}

function clrver() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\clrver.exe $args
}

function disco() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\disco.exe $args
}

function gacutil() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\gacutil.exe $args
}

function resgen() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\resgen.exe $args
}

function sn() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\sn.exe $args
}

function svcutil() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\svcutil.exe $args
}

function wsdl() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\wsdl.exe $args
}

function xsd() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\xsd.exe $args
}

function xsltc() {
    Check-WindowsSdk
    & $script:WindowsSdkPath\xsltc.exe $args
}

##################################################################################################

Export-ModuleMember clrver
Export-ModuleMember disco
Export-ModuleMember gacutil
Export-ModuleMember resgen
Export-ModuleMember sn
Export-ModuleMember svcutil
Export-ModuleMember wsdl
Export-ModuleMember xsd
Export-ModuleMember xsltc
