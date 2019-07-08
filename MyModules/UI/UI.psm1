function Select-Item {
    <#
        .Description
            Produces a list on the screen with a caption followed by a message, the options are then
            displayed one after the other, and the user can one.
        .Example
            PS> select-item -Caption "Configuring RemoteDesktop" -Message "Do you want to: " -choice "&Disable Remote Desktop",
            "&Enable Remote Desktop","&Cancel"  -default 1
        Will display the following:
            Configuring RemoteDesktop
            Do you want to:
            [D] Disable Remote Desktop  [E] Enable Remote Desktop  [C] Cancel  [?] Help (default is "E"):
        .Parameter Choicelist
            An array of strings, each one is possible choice. The hot key in each choice must be prefixed with an & sign
        .Parameter Default
            The zero based item in the array which will be the default choice if the user hits enter.
        .Parameter Caption
            The First line of text displayed
        .Parameter Message
            The Second line of text displayed
        .NOTES
            Originally from:
            https://blogs.technet.microsoft.com/jamesone/2009/06/24/how-to-get-user-input-more-nicely-in-powershell/
    #>

    param (
        [String[]]$choiceList,
        [String]$Caption = "Please make a selection",
        [String]$Message = "Choices are presented below",
        [int]$Default = 0
    )

    $choiceDescription = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]

    $choiceList | ForEach-Object  {
        $choiceDescription.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))
    }

    (Get-Host).UI.PromptForChoice($Caption, $Message, $choiceDescription, $Default)
}

function Set-WindowTitle {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    (Get-Host).UI.RawUI.WindowTitle = $Message
}


###################################################################################################

Set-Alias -Name title -Value Set-WindowTitle
