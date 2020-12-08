function Get-ElasticSearchHealth {
    Invoke-ElasticSearchApi "_cluster/health"
}

function Get-ElasticSearchNode {
    param (
        [string] $Node,
        [string] $Filter
    )

    $result = Invoke-ElasticSearchApi "_cat/nodes?v&pretty"

    if ($Node) {
        $result = $result | Where-Object { $_.name -eq $Node }
    }

    if ($Filter) {
        $result = $result | Where-Object { $_.name -like "*$Filter*" }
    }

    return $result
}

function Get-ElasticSearchNodeDetail {
    param (
        [string] $Node,
        [switch] $All,
        [switch] $Local,
        [switch] $Master
    )

    $method = "_nodes"

    if ($node) {
        $method += "/$Node"
    } else {
        if ($All) {
            $method += "/_all"
        } else {
            if ($Master) {
                $method += "/_master"
            } else {
                if ($Local) {
                    $method += "/_local"
                }
            }
        }
    }

    $result = Invoke-ElasticSearchApi $method

    if ($null -ne $result.nodes) {
        $details = @()
        $keys = ($result.nodes[0] | Get-Member -MemberType NoteProperty).Name

        foreach ($key in $keys) {
            $details += ($result.nodes | Select-Object $key).PSObject.Properties.Value
        }

        $result = $details
    }

    return $result
}

function Get-ElasticSearchState {
    Invoke-ElasticSearchApi "_cluster/state"
}

function Get-ElasticSearchStatistic {
    Invoke-ElasticSearchApi "_cluster/state"
}
