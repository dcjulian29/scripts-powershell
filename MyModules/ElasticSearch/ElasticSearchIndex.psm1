function Get-ElasticSearchIndex {
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName
    )

    Invoke-ElasticSearchApi "$IndexName"
}

function New-ElasticSearchIndex {
    # (PUT)

    # Settings
    # Mappings
    # Aliases
}

function Remove-ElasticSearchIndex {
    # (DELETE)
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
