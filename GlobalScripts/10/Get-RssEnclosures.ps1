function Get-RssEnclosures(
  [Parameter(ValueFromPipeline=$True)][String]$rssUrl,
  [String]$destinationFolder = $pwd.Path)
{
  $client = New-Object Net.WebClient
  
  "Checking $rssUrl..."
  
  $feed = [xml]$client.DownloadString($rssUrl)
  
  $feed.rss.channel.item | foreach `
  {
    $enclosureUrl = $_.enclosure.url    
    $enclosureUrl
    if ($enclosureUrl -ne "")
    {
      $enclosureUrl = new-object Uri($enclosureUrl)
      $filename = (join-path $destinationFolder $enclosureUrl.Segments[-1])
      
      $filename
      
      if ((-not (test-path ($fileName))))
      {
        try
        {
          Get-WebFile $enclosureUrl.AbsoluteUri $filename
        }
        catch [Exception]
        {
          ""
          $_.Exception.Message
          ""
        }
      }
    }
  } 
}
