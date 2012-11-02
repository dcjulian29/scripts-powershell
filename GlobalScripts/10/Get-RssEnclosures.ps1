function Get-RssEnclosures(
  [Parameter(ValueFromPipeline=$True)][String]$rssUrl,
  [String]$destinationFolder = $pwd.Path)
{
  $client = New-Object Net.WebClient
  
  $feed = [xml]$client.DownloadString($rssUrl)
  
  $feed.rss.channel.item | foreach `
  {
    $enclosureUrl = $_.enclosure.url    
    
    if ($enclosureUrl -ne "") {
      $enclosureUrl = new-object Uri($enclosureUrl)
      $filename = (join-path $destinationFolder $enclosureUrl.Segments[-1])
      
      if ((-not (test-path ($fileName))))
      {
        $enclosureUrl.AbsoluteUri
        try
        {
          $client.DownloadFile($enclosureUrl.AbsoluteUri, $filename)
        }
        catch [Exception]
        {
          $_.Exception.Message
        }
      }
    }
  } 
}
