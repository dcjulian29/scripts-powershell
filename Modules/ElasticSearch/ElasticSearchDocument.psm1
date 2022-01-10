function Get-ElasticSearchDocument {
    [CmdletBinding(DefaultParameterSetName = 'multiple')]
    param (
        [Parameter(ParameterSetName = 'single', Mandatory = $true)]
        [Parameter(ParameterSetName = 'multiple', Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName,
        [Parameter(ParameterSetName = 'single', Mandatory = $true)]
        [Alias("Type")]
        [string] $DocumentType,
        [Parameter(ParameterSetName = 'single', Mandatory = $true)]
        [string] $Id,
        [Parameter(ParameterSetName = 'multiple')]
        [string] $Query = "*"

    )

    if ($PSCmdlet.ParameterSetName -eq 'single') {
        Invoke-ElasticSearchApi "$IndexName/$DocumentType/$Id"
    } else {
        (Invoke-ElasticSearchApi "$IndexName/_search?q=*").hits.hits
    }
}

function Find-ElasticSearchDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName,
        [Parameter(Mandatory = $true)]
        [string] $Query
    )

    $result = Invoke-ElasticSearchApi "$IndexName/_search?q=$Query"

    Write-Verbose "Query took $($result.took) ms"

    return $result.hits.hits
}

function New-ElasticSearchDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName,
        [Parameter(Mandatory = $true)]
        [Alias("Type")]
        [string] $DocumentType,
        [Parameter(Mandatory = $true)]
        [string] $Document,
        [string] $Id
    )

    $method = "$IndexName/$DocumentType"

    if ($Id) {
        $method += "/$Id"
    }

    Invoke-ElasticSearchApi -Method $method -HttpMethod "POST" -Body $Document
}

function Remove-ElasticSearchDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName,
        [Parameter(Mandatory = $true)]
        [Alias("Type")]
        [string] $DocumentType,
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-ElasticSearchApi "$IndexName/$DocumentType/$Id" -HttpMethod "DELETE"
}

function Update-ElasticSearchDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias("Name")]
        [string] $IndexName,
        [Parameter(Mandatory = $true)]
        [Alias("Type")]
        [string] $DocumentType,
        [Parameter(Mandatory = $true)]
        [string] $Document,
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    New-ElasticSearchDocument -IndexName $IndexName -DocumentType $DocumentType -Document $Document -Id $Id
}
