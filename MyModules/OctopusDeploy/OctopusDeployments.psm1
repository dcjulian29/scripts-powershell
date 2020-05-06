function buildDeploymentTable($deployments) {
    $table = @()

    foreach ($deployment in $deployments) {
        $row = New-Object PSObject

        $row | Add-Member -Type NoteProperty -Name 'Project' -Value $((Get-OctopusProjectById $deployment.ProjectId).Name)
        $release = Get-OctopusReleaseById $deployment.ReleaseId
        $row | Add-Member -Type NoteProperty -Name 'Release' -Value $release.Version

        $process = Invoke-OctopusApi "deploymentprocesses/$($deployment.DeploymentProcessId)"

        $steps = @()
        $counter = 1
        foreach ($step in $process.Steps) {
            $detail = New-Object PSObject
            $detail | Add-Member -Type NoteProperty -Name 'Step' -Value $counter
            $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $step.Name
            $detail | Add-Member -Type NoteProperty -Name 'Condition' -Value $step.Condition

            $steps += $detail
        }

        $row | Add-Member -Type NoteProperty -Name 'Steps' -Value $steps
        $row | Add-Member -Type NoteProperty -Name 'DeployedAt' -Value $(Get-Date $deployment.Created)

        $table += $row
    }

    return $table
}

#------------------------------------------------------------------------------

function Get-OctopusDeploymentsForEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Environment,
        [int] $Skip = 0,
        [int] $Take = 100,
        [switch] $PassThru
    )

    $environmentId = (Get-OctopusEnvironment -Name $Environment).Id

    $deployments = (Invoke-OctopusApi "deployments?environments=$environmentId&skip=$Skip&take=$Take").Items

    if ($PassThru) {
        return $deployments
    }

    if ($deployments) {
        return buildDeploymentTable($deployments)
    }
}

function Get-OctopusLastDeploymentsForEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Environment
    )

    $environmentId = (Get-OctopusEnvironment -Name $Environment).Id

    $deployments = (Invoke-OctopusApi "deployments?environments=$environmentId&skip=0&take=9999").Items

    $projects = @{}

    foreach ($deployment in $deployments) {
        if ($projects.Contains($deployment.ProjectId)) {
            continue
        }

        $project = New-Object PSObject
        $project | Add-Member -Type NoteProperty -Name 'ProjectId' -Value $deployment.ProjectId
        $project | Add-Member -Type NoteProperty -Name 'ReleaseId' -Value $deployment.ReleaseId
        $project | Add-Member -Type NoteProperty -Name 'DeploymentProcessId' -Value $deployment.DeploymentProcessId
        $project | Add-Member -Type NoteProperty -Name 'Created' -Value $deployment.Created

        $projects.Add($deployment.ProjectId, $project)
    }

    if ($projects) {
        return buildDeploymentTable($projects.Values) | Sort-Object Project
    }
}
