function Approve-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [string] $Comment
    )

    $xml = "<authorizedInfo status=""true"">`n"

    if ($Comment) {
        $xml += "<comment><text>$Comment</text></comment>"
    }

    $xml += "</authorizedInfo>"

    Invoke-TeamCityApi -Method "agents/id:$Id/authorizedInfo" -HttpMethod "PUT" -Body $xml
}

Set-Alias -Name Authorize-TeamCityAgent -Value Approve-TeamCityAgent

function Deny-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [string] $Comment
    )

    $xml = "<authorizedInfo status=""false"">`n"

    if ($Comment) {
        $xml += "<comment><text>$Comment</text></comment>"
    }

    $xml += "</authorizedInfo>"

    Invoke-TeamCityApi -Method "agents/id:$Id/authorizedInfo" -HttpMethod "PUT" -Body $xml
}

Set-Alias -Name Unauthorize-TeamCityAgent -Value Deny-TeamCityAgent

function Disable-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [string] $Comment
    )

    $xml = "<enabledInfo status=""false"">`n"

    if ($Comment) {
        $xml += "<comment><text>$Comment</text></comment>"
    }

    $xml += "</enabledInfo>"

    Invoke-TeamCityApi -Method "agents/id:$Id/enabledInfo" -HttpMethod "PUT" -Body $xml
}

function Enable-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [string] $Comment
    )

    $xml = "<enabledInfo status=""true"">`n"

    if ($Comment) {
        $xml += "<comment><text>$Comment</text></comment>"
    }

    $xml += "</enabledInfo>"

    Invoke-TeamCityApi -Method "agents/id:$Id/enabledInfo" -HttpMethod "PUT" -Body $xml
}

function Get-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id
    )

    $agent = Invoke-TeamCityApi "agents/id:$Id"

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $agent.id
    $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $agent.name
    $detail | Add-Member -Type NoteProperty -Name 'Connected' -Value $agent.connected
    $detail | Add-Member -Type NoteProperty -Name 'Enabled' -Value $agent.enabled
    $detail | Add-Member -Type NoteProperty -Name 'Authorized' -Value $agent.authorized
    $detail | Add-Member -Type NoteProperty -Name 'UpToDate' -Value $agent.uptodate
    $detail | Add-Member -Type NoteProperty -Name 'IP' -Value $agent.ip

    $detail | Add-Member -Type NoteProperty -Name 'Properties' -Value $agent.properties.property

    $pool = New-Object PSObject
    $pool | Add-Member -Type NoteProperty -Name 'Id' -Value $agent.pool.id
    $pool | Add-Member -Type NoteProperty -Name 'Name' -Value $agent.pool.name

    $detail | Add-Member -Type NoteProperty -Name 'Pool' -Value $pool

    return $detail
}

function Get-TeamCityAgentPool {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id
    )

    $pool = Invoke-TeamCityApi "agentPools/id:$Id"

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $pool.id
    $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $pool.name

    $projects = @()

    foreach ($project in $pool.projects.project) {
        $projectDetail = New-Object PSObject
        $projectDetail | Add-Member -Type NoteProperty -Name "Id" -Value $project.id
        $projectDetail | Add-Member -Type NoteProperty -Name "Name" -Value $project.name
        $projectDetail | Add-Member -Type NoteProperty -Name "ParentProjectId" `
            -Value $project.parentProjectId

        $projects += $projectDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Projects' -Value $projects

    $agents = @()

    foreach ($agent in $pool.agents.agent) {
        $agentDetail = New-Object PSObject
        $agentDetail | Add-Member -Type NoteProperty -Name "Id" -Value $agent.id
        $agentDetail | Add-Member -Type NoteProperty -Name "Name" -Value $agent.name

        $agents += $agentDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Agents' -Value $agents

    return $detail
}

function Get-TeamCityAgentPools {
    (Invoke-TeamCityApi "agentPools/id:$Id").agentPool
}

function Get-TeamCityAgents {
    param (
        [switch] $Authorized,
        [switch] $Connected,
        [switch] $Enabled,
        [switch] $Disabled
    )

    $locator = @(
        "defaultFilter:false"
    )

    if ($Authorized) {
        $locator += "authorized:true"
    }

    if ($Connected) {
        $locator += "connected:true"
    }

    if ($Enabled) {
        $locator += "enabled:true"
    } else {
        if ($Disabled) {
            $locator += "enabled:false"
        }
    }

    $agents = @()

    foreach ($id in (Invoke-TeamCityApi "agents?locator=$($locator -join ',')").agent.id) {
        $agent = Get-TeamCityAgent $id
        $agents += $agent
    }

    return $agents
}

function Move-TeamCityAgent {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [int] $Pool
    )

    $xml = "<agent id='$Id'/>"

    Invoke-TeamCityApi -Method "agentPools/id:$Pool/agents" -HttpMethod "POST" -Body $xml
}
