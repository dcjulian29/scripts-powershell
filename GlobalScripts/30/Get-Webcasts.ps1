function Get-Webcasts
{
  param
  (
    [bool]$downloadFiles = $true
  )
  

  $baseDirectory = "D:\Webcasts"
  $opmlFile = $baseDirectory + "\webcasts.opml"

  $opml = [xml](Get-Content $opmlFile)
  $opml.opml.body.outline | `
    foreach { Get-WebcastsFromRSS $_.xmlUrl $baseDirectory $downloadFiles $true }
}
