function Get-TeamCityBuild {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $build = Invoke-TeamCityApi "builds/id:$Id"

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $build.id
    $detail | Add-Member -Type NoteProperty -Name 'BuildTypeId' -Value $build.buildTypeId
    $detail | Add-Member -Type NoteProperty -Name 'Number' -Value $build.number
    $detail | Add-Member -Type NoteProperty -Name 'Status' -Value $build.status
    $detail | Add-Member -Type NoteProperty -Name 'StatusTest' -Value $build.statusText
    $detail | Add-Member -Type NoteProperty -Name 'State' -Value $build.state
    $detail | Add-Member -Type NoteProperty -Name 'Branch' -Value $build.branchName

    $queued = [DateTime]::ParseExact($build.queuedDate, 'yyyyMMddTHHmmssK', $null)
    $start = [DateTime]::ParseExact($build.startDate, 'yyyyMMddTHHmmssK', $null)
    $finish = [DateTime]::ParseExact($build.finishDate, 'yyyyMMddTHHmmssK', $null)
    $elapsed = ($finish - $start).ToString()
    $timeInQueue = ($start - $queued).ToString()

    $detail | Add-Member -Type NoteProperty -Name 'Queued' -Value $queued
    $detail | Add-Member -Type NoteProperty -Name 'Started' -Value $start
    $detail | Add-Member -Type NoteProperty -Name 'Finished' -Value $finish
    $detail | Add-Member -Type NoteProperty -Name 'Elasped' -Value $elapsed
    $detail | Add-Member -Type NoteProperty -Name 'TimeInQueue' -Value $timeInQueue

    switch ($build.triggered.type) {
        "vcs" {
            $triggered = "VCS"
         }
        "user" {
            $triggered = "User: $($build.triggered.user.username)"
         }
        Default {
            $triggered = "Unknown"
        }
    }

    $detail | Add-Member -Type NoteProperty -Name 'TriggeredBy' -Value $triggered

    $changes = @()

    foreach ($change in $build.lastChanges.change) {
        $changeDetail = New-Object PSObject
        $changeDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $change.id
        $changeDetail | Add-Member -Type NoteProperty -Name 'Version' -Value $change.version
        $changeDetail | Add-Member -Type NoteProperty -Name 'User' -Value $change.username

        $commit = [DateTime]::ParseExact($change.date, 'yyyyMMddTHHmmssK', $null)
        $changeDetail | Add-Member -Type NoteProperty -Name 'Date' -Value $commit

        $changes += $changeDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Changes' -Value $changes

    $agent = New-Object PSObject
    $agent | Add-Member -Type NoteProperty -Name 'Id' -Value $build.agent.id
    $agent | Add-Member -Type NoteProperty -Name 'Name' -Value $build.agent.name

    $detail | Add-Member -Type NoteProperty -Name 'Agent' -Value $agent

    return $detail
}

function Get-TeamCityBuildQueue {
    (Invoke-TeamCityApi "buildQueue").build
}

function Get-TeamCityBuildQueueDetail {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-TeamCityApi "buildQueue/id:$Id"
}

function Get-TeamCityBuilds {
    param (
        [string] $ProjectId,
        [string] $BuildNumber,
        [int] $Start = 0,
        [int] $Take = 9999,
        [ValidateSet("Success", "Failure", "All")]
        [string] $Status = "All",
        [ValidateSet("Queued", "Running", "Finished", "All")]
        [string] $State = "All",
        [DateTime] $SinceDate,
        [switch] $OnlyPersonal,
        [switch] $Canceled,
        [switch] $FailedToStart
    )

    $locator = @(
        "start:$Start"
        "count:$Take"
    )

    if ($Status -ne "All") {
        $locator += "status:{0}" -f $Status.ToLowerInvariant()
    }

    if ($OnlyPersonal) {
        $locator += "personal:true"
    }

    if ($Canceled) {
        $locator += "canceled:true"
    }

    if ($FailedToStart) {
        $locator += "failedToStart:true"
    }

    if ($State -ne "All") {
        $locator += "state:{0}" -f $State.ToLowerInvariant()
    }

    if ($SinceDate) {
        $locator += "sinceDate:{0}" `
            -f $SinceDate.ToString('yyyyMMddTHHmmsszzz').Replace(':', '')
    }

    $locator += "branch:default:any"

    if ($ProjectId) {
        $locator += "project:id:$ProjectId"
    }

    if ($BuildNumber) {
        $locator += "number:$BuildNumber"
    }

    $locator += "defaultFilter:false"

    $builds = @()

    foreach ($build in (Invoke-TeamCityApi "builds?locator=$($locator -join ',')").build) {
        $detail = New-Object PSObject
        $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $build.id
        $detail | Add-Member -Type NoteProperty -Name 'BuildTypeId' -Value $build.buildTypeId
        $detail | Add-Member -Type NoteProperty -Name 'Number' -Value $build.number
        $detail | Add-Member -Type NoteProperty -Name 'Status' -Value $build.status
        $detail | Add-Member -Type NoteProperty -Name 'State' -Value $build.state
        $detail | Add-Member -Type NoteProperty -Name 'Branch' -Value $build.branchName

        $builds += $detail
    }

    return $builds
}

function Get-TeamCityBuildStatistics {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    (Invoke-TeamCityApi "builds/id:$Id/statistics").property
}

function Get-TeamCityBuildTests {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $result = (Invoke-TeamCityApi "testOccurrences?locator=build:(id:$Id)").testOccurrence

    $tests = @()

    foreach ($test in $result) {
        $testDetails = New-Object PSObject
        $testDetails | Add-Member -Type NoteProperty -Name 'Name' `
            -Value (($test.name).Split(':')[1]).Trim()
        $testDetails | Add-Member -Type NoteProperty -Name 'Status' -Value $test.status
        $testDetails | Add-Member -Type NoteProperty -Name 'Duration' -Value $test.duration

        $tests += $testDetails
    }

    return $tests
}

function Start-TeamCityBuild {
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Id")]
        [string] $BuildConfigurationId,
        [string] $Branch,
        [string] $Comment,
        [switch] $PersonalBuild,
        [switch] $QueueAtTop,
        [bool] $CleanSources = $true,
        [bool] $RebuildDependencies = $true
    )

    if ($Branch) {
        $branchName = " branchName=""$Branch"""
    }

    $xml = @"
<build personal="$($PersonalBuild.IsPresent)"$branchName>
    <buildType id="$BuildConfigurationId"/>
    <triggeringOptions cleanSources="$CleanSources"
                       rebuildAllDependencies="$RebuildDependencies"
                       queueAtTop="$($QueueAtTop.IsPresent)"/>`n
"@

    if ($Comment) {
        $xml += "    <comment><text>$Comment</text></comment>`n"
    }

    $xml += "</build>"

    Invoke-TeamCityApi -Method "buildQueue" -HttpMethod "POST" -Body $xml
}

function Stop-TeamCityBuild {
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Id")]
        [string] $BuildId,
        [string] $Comment,
        [switch] $AddToQueue
    )

    $xml = "<buildCancelRequest comment='$Comment' readdIntoQueue='$($AddToQueue.IsPresent)' />"

    Invoke-TeamCityApi -Method "builds/id:$BuildId" -HttpMethod "POST" -Body $xml
}
