Function Format-XML {
    param (
        [xml] $xml,
        [int] $indent = 4
    )

    $stringWriter = New-Object System.IO.StringWriter

    $writer = New-Object System.Xml.XmlTextWriter $stringWriter
    $writer.Formatting = "indented"
    $writer.Indentation = $indent

    $xml.WriteContentTo($writer)

    $writer.Flush()
    $StringWriter.Flush()

    Write-Output $StringWriter.ToString()
}


Export-ModuleMember Format-Xml