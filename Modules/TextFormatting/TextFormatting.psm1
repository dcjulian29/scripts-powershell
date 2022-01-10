Function Format-XML {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [psobject] $Xml,
        [int] $Indent = 4,
        [switch] $NoNewLineOnAttribute
    )
    
    BEGIN {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Xml") | Out-Null
        $XmlText = ""
    }
    
    PROCESS {
        $XmlText = $XmlText + $Xml
    }
    
    END {
        $XmlText = [xml]$XmlText
        
        if (-not $XmlText ) { return }
        
        $stringWriter = New-Object System.IO.StringWriter
        
        $settings = new-object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $settings.IndentChars = " " * $Indent
        $settings.NewLineChars = "`r`n"
        if (-not ($NoNewLineOnAttribute)) {
            $settings.NewLineOnAttributes = $true
        }
        
        $settings.OmitXmlDeclaration = $false
        $settings.CheckCharacters = $true

        $settings.NamespaceHandling = [System.Xml.NamespaceHandling]::OmitDuplicates

        
        $writer = [Xml.XmlWriter]::Create($stringWriter, $settings)
        
        $XmlText.WriteContentTo($writer)

        $writer.Flush()
        $StringWriter.Flush()

        Write-Output $StringWriter.ToString()
    }
}

Function Format-Json {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Json
    )
    
    BEGIN {
        $JsonText = ""
    }
    
    PROCESS {
        $JsonText = $JsonText + $Json
    }
    
    END {
        if (-not $JsonText ) { return }

        $JsonText | ConvertFrom-Json | ConvertTo-Json
    }
}


Export-ModuleMember Format-Xml
Export-ModuleMember Format-Json