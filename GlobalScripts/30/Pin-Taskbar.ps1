Function Pin-Taskbar {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Item,

        [ValidateSet("Pin","Unpin")]
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Action
    )

    $Item = Resolve-Path $Item
    $ItemParent = Split-Path -Path $Item -Parent
    $ItemLeaf = Split-Path -Path $Item -Leaf

    $Shell = New-Object -ComObject "Shell.Application"
    $Folder = $Shell.NameSpace($ItemParent)
    $ItemObject = $Folder.ParseName($ItemLeaf)
    $Verbs = $ItemObject.Verbs()

    switch($Action) {
        "Pin"   {
            $Verb = $Verbs | Where-Object -Property Name -EQ "Pin to Tas&kbar"
        }

        "Unpin" {
            $Verb = $Verbs | Where-Object -Property Name -EQ "Unpin from Tas&kbar"
        }
    }

    $Result = $Verb.DoIt()
}
