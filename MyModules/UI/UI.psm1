function Get-BingWallpaper {
    <#
        .DESCRIPTION
            Bing Search has fantastic background pictures. This command gets them downloaded to
            your local pictures folder.

        .PARAMETER Resolution
            Sets the picture size to look for. If the specified resolution cannot be found,
            the next lower resolution will be searched. You will get an error showing that
            the specified resolution cannot be found.

            The default is 1080p, which is usually 1920x1200.

        .PARAMETER Region
            Sets the region to look for. Bing has 8 regions.
    #>

    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Standard", "StandardWide", "HD", "1080p")]
        [String]$Resolution = '1080p',
        [ValidateSet('auto', 'ar-XA', 'bg-BG', 'cs-CZ', 'da-DK', 'de-AT',
            'de-CH', 'de-DE', 'el-GR', 'en-AU', 'en-CA', 'en-GB', 'en-ID',
            'en-IE', 'en-IN', 'en-MY', 'en-NZ', 'en-PH', 'en-SG', 'en-US',
            'en-XA', 'en-ZA', 'es-AR', 'es-CL', 'es-ES', 'es-MX', 'es-US',
            'es-XL', 'et-EE', 'fi-FI', 'fr-BE', 'fr-CA', 'fr-CH', 'fr-FR',
            'he-IL', 'hr-HR', 'hu-HU', 'it-IT', 'ja-JP', 'ko-KR', 'lt-LT',
            'lv-LV', 'nb-NO', 'nl-BE', 'nl-NL', 'pl-PL', 'pt-BR', 'pt-PT',
            'ro-RO', 'ru-RU', 'sk-SK', 'sl-SL', 'sv-SE', 'th-TH', 'tr-TR',
            'uk-UA', 'zh-CN', 'zh-HK', 'zh-TW')]
        [string]$Region = 'auto',
        [switch]$PassThru
    )

	$localFolder = Join-Path $env:TEMP 'Bing'
	$bingUrl = 'http://www.bing.com'

    Switch ($Resolution)
    {
        'Standard' { $imageResolution = '1024x768' }
        'StandardWide' { $imageResolution = '1280x720' }
        'HD' { $imageResolution = '1366x768' }
        '1080p' { $imageResolution = '1920x1200' }
    }

    $wallpaper = '{0}/HPImageArchive.aspx?format=xml&idx={1}&n=8&mkt={2}' -f $bingUrl, 0, $Region

    $request = Invoke-WebRequest -Uri $wallpaper
    [xml]$content = $request.Content

    $image = $content.images.image[0]

    $fallbackUrl = '{0}{1}' -f $bingUrl, $image.url
    $downloadUrl = '{0}{1}_{2}.jpg' -f $bingUrl, $image.urlBase, $imageResolution

    $saveAs = $downloadUrl.Substring($downloadUrl.LastIndexOf('/') + 1)
    $saveAs = [RegEx]::Replace($saveAs, "[{0}]" `
        -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')

    $saveAsPath = Join-Path $localFolder $saveAs

    if (-not (Test-Path $localFolder)) {
        New-Item -Path $localFolder -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path $saveAsPath -PathType Leaf)) {
        Download-File -Url $downloadUrl -Destination $saveAsPath -ErrorAction Continue

        if (-not (Test-Path $saveAsPath -PathType Leaf)) {
            Download-File -Url $fallbackUrl -Destination $saveAsPath -ErrorAction Continue
        }
	}

    if ($PassThru) {
        "$saveAsPath"
    }
}

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

function Set-BingDesktopWallpaper {
    Get-BingWallpaper -PassThru | Set-DesktopWallpaper
}

function Set-DesktopWallpaper {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    Set-ItemProperty Wallpaper -Path "HKCU:\Control Panel\Desktop" -Value $Path

    $i=0
    while ($i -le 25) {
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
        $i++
    }
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
