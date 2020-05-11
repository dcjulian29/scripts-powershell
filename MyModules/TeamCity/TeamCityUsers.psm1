function Get-TeamCityUser {
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id
    )

    $user = Invoke-TeamCityApi "users/id:$Id"

    $detail = New-Object PSObject
    $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $user.id
    $detail | Add-Member -Type NoteProperty -Name 'UserName' -Value $user.username
    $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $user.name

    $lastLogin = [DateTime]::ParseExact($user.lastLogin, 'yyyyMMddTHHmmssK', $null)

    $detail | Add-Member -Type NoteProperty -Name 'LastLogin' -Value $lastLogin

    $roles = @()

    foreach ($role in $user.roles.role) {
        $roleDetail = New-Object PSObject
        $roleDetail | Add-Member -Type NoteProperty -Name 'RoleId' -Value $role.roleId
        $roleDetail | Add-Member -Type NoteProperty -Name 'Scope' -Value $role.scope

        $roles += $roleDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Roles' -Value $roles

    $groups = @()

    foreach ($group in $user.groups.group) {
        $groupDetail = New-Object PSObject
        $groupDetail | Add-Member -Type NoteProperty -Name 'Key' -Value $group.key
        $groupDetail | Add-Member -Type NoteProperty -Name 'Name' -Value $group.name

        $groups += $groupDetail
    }

    $detail | Add-Member -Type NoteProperty -Name 'Groups' -Value $groups

    return $detail
}

function Get-TeamCityUsers {
    $users = @()

    foreach ($user in (Invoke-TeamCityApi "users").user) {
        $detail = New-Object PSObject
        $detail | Add-Member -Type NoteProperty -Name 'Id' -Value $user.id
        $detail | Add-Member -Type NoteProperty -Name 'Name' -Value $user.name

        $users += $detail
    }

    return $users
}
