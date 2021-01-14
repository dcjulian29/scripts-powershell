function Get-ElasticSearchIndex {
    param (
        [Alias("Name")]
        [string] $IndexName
    )

    if ($IndexName) {
        (Invoke-ElasticSearchApi "$IndexName").$IndexName
    } else {
        Invoke-ElasticSearchApi "_cat/indices"
    }
}

function Get-ElasticSearchIndexDocumentCount {
    param (
        [string] $Filter,
        [switch] $Not
    )

    $indexes = Get-ElasticSearchIndex | Select-Object index, health, 'docs.count', 'store.size'

    if ($Filter) {
        if ($Not) {
            $indexes = $indexes | Where-Object { $_.index -notlike "*$Filter*" }
        } else {
            $indexes = $indexes | Where-Object { $_.index -like "*$Filter*" }
        }
    }

    $indexes = $indexes | Sort-Object index

    return $indexes
}

function New-ElasticSearchIndex {
    # (PUT)

    # Settings
    # Mappings
    # Aliases
}

function Remove-ElasticSearchIndex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $IndexPattern
    )

    Invoke-ElasticSearchApi -Method "$IndexPattern" -HttpMethod DELETE
}

function Test-ElasticSearchIndex {
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName
    )

    Use-ElasticSearchProfile

    $uri = "$env:ElasticSearchUrl/$IndexName"

    try {
        $response = (Invoke-WebRequest -Uri $uri -Method "HEAD").StatusCode
    } catch {
        $response = $_.Exception.Response.StatusCode.Value__
    }

    if ($response -eq 200) {
        return $true
    }

    return $false
}

function Update-ElastSearchIndex {
    # (PUT???)
}
