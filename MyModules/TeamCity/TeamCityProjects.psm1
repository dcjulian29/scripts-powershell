function Get-TeamCityBuildConfiguration {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id,
        [switch] $PassThru
    )

    $conf = Invoke-TeamCityApi "buildTypes/id:$Id"

    if ($PassThru) {
        return $conf
    }

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $conf.id
    $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $conf.name
    $detail | Add-Member -Type NoteProperty -Name 'ProjectId' -Value $conf.projectId

    $vcs = @()

    foreach ($root in $conf.'vcs-root-entries'.'vcs-root-entry') {
        $rootDetail = New-Object PSObject
        $rootDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $root.id
        $rootDetail | Add-Member -Type NoteProperty -Name 'Name' -Value $root.Name

        $vcs += $rootDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'VcsRoots' -Value $vcs
    $detail | Add-Member -Type NoteProperty -Name 'Settings' -Value $conf.settings.property
    $detail | Add-Member -Type NoteProperty -Name 'Parameters' -Value $conf.parameters.property

    $stepList = @()

    foreach ($step in $conf.steps.step) {
        $stepDetail = New-Object PSObject
        $stepDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $step.id
        $stepDetail | Add-Member -Type NoteProperty -Name 'Name' -Value $step.Name
        $stepDetail | Add-Member -Type NoteProperty -Name 'Properties' -Value $step.properties.property

        $stepList += $stepDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Steps' -Value $stepList

    $featureList = @()

    foreach ($feature in $conf.features.feature) {
        $featureDetail = New-Object PSObject
        $featureDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $feature.id
        $featureDetail | Add-Member -Type NoteProperty -Name 'Type' -Value $feature.type
        $featureDetail | Add-Member -Type NoteProperty -Name 'Disabled' -Value $feature.disabled
        $featureDetail | Add-Member -Type NoteProperty -Name 'Properties' `
            -Value $feature.properties.property

        $featureList += $featureDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Features' -Value $featureList

    $triggerList = @()

    foreach ($trigger in $conf.triggers.trigger) {
        $triggerDetail = New-Object PSObject
        $triggerDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $trigger.id
        $triggerDetail | Add-Member -Type NoteProperty -Name 'Type' -Value $trigger.type
        $triggerDetail | Add-Member -Type NoteProperty -Name 'Disabled' -Value $trigger.disabled
        $triggerDetail | Add-Member -Type NoteProperty -Name 'Properties' `
            -Value $trigger.properties.property

        $triggerList += $triggerDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Triggers' -Value $triggerList

    return $detail
}

function Get-TeamCityBuildConfigurations {
    $configurations = (teamcityapi "buildTypes").buildType

    $list = @()

    foreach ($configuration in $configurations) {
        $detail = New-Object PSObject
        $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $configuration.id
        $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $configuration.name
        $detail | Add-Member -Type NoteProperty -Name 'ProjectId' -Value $configuration.projectId

        $list += $detail
    }

    $list
}

function Get-TeamCityProject {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [switch] $PassThru
    )

    $project = Invoke-TeamCityApi "projects/name:$Name"

    if ($project) {
        Get-TeamCityProjectById $project.id $PassThru.IsPresent
    }
}

function Get-TeamCityProjectById {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id,
        [switch] $PassThru
    )

    $project = Invoke-TeamCityApi "projects/id:$Id"

    if ($PassThru) {
        return $project
    }

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $project.id
    $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $project.name
    $detail | Add-Member -Type NoteProperty -Name 'ParentProjectId' -Value $project.parentProjectId

    $configurations = @()

    foreach ($step in $project.buildTypes.buildType) {
        $configuration = New-Object PSObject
        $configuration | Add-Member -Type NoteProperty -Name 'Id' -Value $step.id
        $configuration | Add-Member -Type NoteProperty -Name 'Name' -Value $step.Name

        $configurations += $configuration
    }

    $detail | Add-Member -Type NoteProperty -Name 'BuildConfigurations' -Value $configurations
    $detail | Add-Member -Type NoteProperty -Name 'Parameters' -Value $project.parameters.property

    $featureList = @()

    foreach ($feature in $project.projectFeatures.projectFeature) {
        $featureDetail = New-Object PSObject
        $featureDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $feature.id
        $featureDetail | Add-Member -Type NoteProperty -Name 'Type' -Value $feature.type
        $featureDetail | Add-Member -Type NoteProperty -Name 'Properties' `
            -Value $feature.properties.property

        $featureList += $featureDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Features' -Value $featureList

    $vcsRoots = Invoke-TeamCityApi "vcs-roots?locator=project:(id:$Id)"
    $vcs = @()

    foreach ($root in $vcsRoots.'vcs-root') {
        $rootDetail = New-Object PSObject
        $rootDetail | Add-Member -Type NoteProperty -Name 'Id' -Value $root.id
        $rootDetail | Add-Member -Type NoteProperty -Name 'Name' -Value $root.Name

        $vcs += $rootDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'VcsRoots' -Value $vcs

    return $detail
}

function Get-TeamCityProjects {
    $projects = (Invoke-TeamCityApi "projects").project

    $projectList = @()

    foreach ($project in $projects) {
        $detail = New-Object PSObject
        $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $project.id
        $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $project.name
        $detail | Add-Member -Type NoteProperty -Name 'ParentProjectId' -Value $project.parentProjectId

        if ($project.archived) {
            $detail | Add-Member -Type NoteProperty -Name 'Archived' -Value $project.archived
        } else {
            $detail | Add-Member -Type NoteProperty -Name 'Archived' -Value 'false'
        }

        $projectList += $detail
    }

    $projectList
}
