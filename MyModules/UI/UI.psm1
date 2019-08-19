function Get-BingWallpaper {
    param (
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

    $wallpaper = '{0}/HPImageArchive.aspx?format=xml&idx={1}&n=8&mkt={2}' -f $bingUrl, 0, $Region

    $request = Invoke-WebRequest -Uri $wallpaper
    [xml]$content = $request.Content

    $image = $content.images.image[0]

    $downloadUrl = '{0}{1}' -f $bingUrl, $image.url

    $saveAs = $image.url.Substring($image.url.IndexOf('=') + 1)
    $saveAs = $saveAs.Substring(0,$saveAs.IndexOf('&'))
    $saveAs = [RegEx]::Replace($saveAs, "[{0}]" `
        -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')

    $saveAsPath = Join-Path $localFolder $saveAs

    if (-not (Test-Path $localFolder)) {
        New-Item -Path $localFolder -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path $saveAsPath -PathType Leaf)) {
        Download-File -Url $downloadUrl -Destination $saveAsPath -ErrorAction Continue
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

function Set-BingWallpaperScheduledTask {
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $sid = ([System.DirectoryServices.AccountManagement.UserPrincipal]::Current).SID.Value

    $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "s")</Date>
    <Author>$env:USERDOMAIN\$env:USERNAME</Author>
    <URI>\Update Desktop Background</URI>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>$(Get-Date -Format"yyyy-MM-dd")T06:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$env:USERDOMAIN\$env:USERNAME</UserId>
    </LogonTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="System"&gt;&lt;Select Path="System"&gt;*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and EventID=107]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$sid</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>false</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Command>
      <Arguments>-WindowStyle Hidden -Command "Set-BingDesktopWallpaper" -Noninteractive</Arguments>
    </Exec>
  </Actions>
</Task>
"@

    Register-ScheduledTask -TaskName "Update Desktop Wallpaper" -Xml $xml -Force
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
