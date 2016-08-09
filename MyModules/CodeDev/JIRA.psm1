$script:JiraUrl = ''
$script:JiraUserName = ''
$script:JiraHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

$script:JiraNew = ''
$script:StartTransition = ''
$script:FinishTransition = ''

###############################################################################

Function IsConnected {
    return ($($script:JiraHeader).Count -gt 0)
}

###############################################################################

Function Clear-JiraProfile {
    $script:JiraUrl = ''

    $script:JiraNew = ''
    $script:StartTransition = ''
    $script:FinishTransition = ''
}

Function Get-JiraProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the JIRA Profile")
    )
    
    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/jira" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "JIRA Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $script:JiraUrl = $json.Url

        $script:JiraNew = $json.New
        $script:StartTransition = $json.StartTransition
        $script:FinishTransition = $json.FinishTransition

        $script:JiraHeader.Clear()
    }
}

Function Connect-JiraServer {
    param (
        [string]$ProfileName,
        [psobject]$Credentials
    )

    if (($ProfileName.Length -eq 0) -and ($($script:JiraUrl).Length -eq 0)) {
        Write-Error "Please provide the JIRA profile or load a JIRA profile before calling this command."
        return
    }

    if (($ProfileName.Length -gt 0) -and ($($script:JiraHeader).Count -gt 0)) {
        Write-Error "Already connected to a JIRA server. Please disconnect first."
        return
    }

    if ($Credentials -eq $null) {
        if ($($script:JiraHeader).Count -gt 0) {
            Write-Error "Already connected to a JIRA server. Please disconnect first."
            return
        }

        $Credentials = (Get-Credential -Message "Enter JIRA Credentials")
    }

    if (($ProfileName.Length -gt 0) -and ($($script:JiraHeader).Count -eq 0)) {
        Get-JiraProfile $ProfileName
    }

    $script:JiraUserName = $Credentials.UserName
    $password = $Credentials.GetNetworkCredential().Password
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Utf8.GetBytes("$($script:JiraUserName):$password"))

    $script:JiraHeader.Clear()
    $script:JiraHeader.Add("Authorization", "Basic $encoded")
    $script:JiraHeader.Add("Content-Type", 'application/json')

    $url = "$($script:JiraUrl)/rest/api/2/search?jql=assignee=$($script:JiraUserName)"

    try {
        $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url
    } catch [System.Net.WebException] {
        Write-Error "Unable to connect to JIRA server. $($_.Exception.Message)"

        $script:JiraHeader.Clear()
    }


}

Function Disconnect-JiraServer {
    $script:JiraHeader.Clear()
}

Function Show-JiraServer {
    if (IsConnected) {
        Write-Output "Currently connected to $($script:JiraUrl)"
    } else {
        if ($($script:JiraUrl).Length -eq 0) {
            Write-Warning "No JIRA server configured."
        } else {
            Write-Output "Currently not connected to $($script:JiraUrl)"
        }
    }
}

Function Show-JiraUser {
    if (IsConnected) {
        Write-Output "Currently connected to $($script:JiraUrl) as $($script:JiraUserName)"
    } else {
        if ($($script:JiraUrl).Length -eq 0) {
            Write-Warning "No JIRA server configured."
        } else {
            Write-Output "Currently not connected to $($script:JiraUrl)"
        }
    }
}

Function Invoke-Jira {
    [CmdletBinding()]
    param (
        [string]$ProfileName
    )

    if (($ProfileName.Length -eq 0) -and ($($script:JiraUrl).Length -eq 0)) {
        Write-Error "Please provide the JIRA profile or load a JIRA profile before calling this command."
        return
    }

    if ($ProfileName.Length -gt 0) {
        $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/jira" -ChildPath "$ProfileName.json"

        if (-not (Test-Path $profileFile)) {
            Write-Error "JIRA Profile does not exist!"
        } else {
            $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

            $url = $json.Url
        }
    } else {
        $url = $script:JiraUrl
    }

    Write-Verbose "Launching $url in default browser..."
    Start-Process $url
}

Function Get-MyJiraTickets {
    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/search?jql=assignee=$($script:JiraUserName)"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url


    $line = @{Expression={$_.key};Label="ID";width=10}, `
            @{Expression={$_.fields.issuetype.name};Label="Type";width=8}, `
            @{Expression={$_.fields.status.name};Label="Status";width=12}, `
            @{Expression={$_.fields.summary};Label="Summary";width=80}

    $json.issues | Format-Table $line
}

Function Get-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    return $json
}

Function Get-JiraTicketComments {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [switch]$List
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/comment"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    if ($List) {
        $line = @{Expression={$_.author.displayName};Label="Who"}, `
                @{Expression={Get-date $_.updated -Format "MM/dd/yyyy h:mm"};Label="When"}, `
                @{Expression={$_.body};Label="What"}
        $json.comments | Format-List $line
    } else {
        $line = @{Expression={$_.author.displayName};Label="Who";width=20}, `
                @{Expression={Get-date $_.updated -Format "MM/dd/yyyy h:mm"};Label="When";width=12}, `
                @{Expression={$_.body};Label="What";width=80}
        $json.comments | Format-Table $line -Wrap
    }
}

Function Get-JiraTicketStatus {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    return $json.fields.status.name
}

Function Start-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/transitions"

    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $transitionId = $($json.transitions | Where-Object { $_.name -eq "$($script:StartTransition)"}).id

    if (-not $transitionId) {
        Write-Error "Invalid transition for that ticket. Current ticket status is: `"$(Get-JiraTicketStatus $Ticket)`""
        return
    }

    if ($Comment) {
        $updateJSON = @"
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "$comment"
                }
            }
        ]
    },
    "transition": {
            "id": "$transitionId"
    }
}
"@
    } else {
        $updateJSON = @"
{
    "transition": {
            "id": "$transitionId"
    }
}
"@
    }

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Finish-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/transitions"

    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $transitionId = $($json.transitions | Where-Object { $_.name -eq "$($script:FinishTransition)"}).id

    if (-not $transitionId) {
        Write-Error "Invalid transition for that ticket. Current ticket status is: `"$(Get-JiraTicketStatus $Ticket)`""
        return
    }

    if ($Comment) {
        $updateJSON = @"
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "$comment"
                }
            }
        ]
    },
    "transition": {
            "id": "$transitionId"
    }
}
"@
    } else {
        $updateJSON = @"
{
    "transition": {
            "id": "$transitionId"
    }
}
"@
    }

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Add-JiraTicketComment {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment = $(Read-Host "Enter Comment for Ticket")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/comment"

    $updateJSON = @"
{
    "body": "$comment"
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Get-JiraTicketWatchers {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $line = @{Expression={$_.name};Label="ID";width=15}, `
            @{Expression={$_.displayName};Label="Name";width=25}

    $json.watchers | Format-Table $line
}

Function Add-JiraTicketWatcher {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$UserName = $(Read-Host "Enter UserName")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers"

    $update = "$UserName"

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $update
}

Function Remove-JiraTicketWatcher {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$UserName = $(Read-Host "Enter UserName")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers?username=$UserName"

    Invoke-RestMethod -Method DELETE -Headers $script:JiraHeader -Uri $url
}

Function Ping-JiraTicketWatchers {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Subject = $(Read-Host "Enter Subject" ),
        [string]$Message = $(Read-Host "Enter message for ticket watchers")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/notify"

    $updateJSON = @"
{
    "subject": "$Subject",
    "textBody": "$Message",
    "to": {
        "reporter": false,
        "assignee": false,
        "watchers": true,
        "voters": false
    }
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Add-TimeSpentOnJiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA ticket number"),
        [string]$Comment = $(Read-Host "Enter comment for ticket"),
        [datetime]$When, 
        [string]$Minutes = $(Read-Host "Enter number of hours spent on this ticket")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/worklog"

    if (-not $When) {
        $started = ([DateTime]::Now.AddMinutes(0 - [double]$Minutes)).ToString('o')
    } else {
        $started = $When.ToString('o') + $When.ToString('zzz');
    }

    $seconds = [double]$Minutes * 60

    $json = @"
{
    "comment": "$comment",
    "started": "$started",
    "timeSpentSeconds": $seconds
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $json
}

###############################################################################

Export-ModuleMember Add-JiraTicketComment
Export-ModuleMember Add-JiraTicketWatcher
Export-ModuleMember Add-TimeSpentOnJiraTicket
Export-ModuleMember Clear-JiraProfile
Export-ModuleMember Connect-JiraServer
Export-ModuleMember Disconnect-JiraServer
Export-ModuleMember Finish-JiraTicket
Export-ModuleMember Get-JiraProfile
Export-ModuleMember Get-JiraTicket
Export-ModuleMember Get-JiraTicketComments
Export-ModuleMember Get-JiraTicketStatus
Export-ModuleMember Get-JiraTicketWatchers
Export-ModuleMember Get-MyJiraTickets
Export-ModuleMember Invoke-Jira
Export-ModuleMember Ping-JiraTicketWatchers
Export-ModuleMember Remove-JiraTicketWatcher
Export-ModuleMember Show-JiraServer
Export-ModuleMember Show-JiraUser
Export-ModuleMember Start-JiraTicket

Set-Alias jira-profile-clear Clear-JiraProfile
Set-Alias jira-profile-load Get-JiraProfile

Export-ModuleMember -Alias jira-profile-clear
Export-ModuleMember -Alias jira-profile-load
