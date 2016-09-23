function Compare-OPML
{
  param
  (
    [string]$opmlFile1,
    [string]$opmlFile2
  )
  
  $o1 = [xml](Get-Content $opmlFile1)
  $o2 = [xml](Get-Content $opmlFile2)
  
  $f1 = ($o1.opml.body.outline.text | sort)
  $f2 = ($o2.opml.body.outline.text | sort)
  
  ""
  "<= $opmlFile1"
  "=> $opmlFile2"
  ""
  
  Compare-Object $f1 $f2
}
