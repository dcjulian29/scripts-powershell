function Find-PSCommand {
    param (
        [string]$Filter
    )

    Get-Command | Where-Object { $_.Name -like "*$Filter*" } | Sort-Object Name | Format-Table Name,Version, Source
}
