function Find-NoRssPostInMonths
{
  [CmdletBinding()]
  param
  (
    [int]$months,
    [string]$opmlFile
  )
  
  $client = New-Object Net.WebClient
  $monthsAgo = [DateTime]::Today.AddMonths(0-$months)
  
  $opml = [xml](Get-Content $opmlFile)
  $opml.opml.body.outline | foreach `
  {
    $response = $client.DownloadString($_.xmlUrl)
    $feed = [xml]$response.Substring($response.IndexOf('<'))
    $feedTitle = $feed.rss.channel.title
  
    $item = $feed.rss.channel.item[0]
    if ($item -eq $null)
    {
          $item = $feed.rss.channel.item
    }

    Write-Verbose "     Feed: $($feedTitle)"
    Write-Verbose "Last Post: $($pubdate)"
    
    # sometimes items have a non-parsable US Timezone such as 'EDT' or 'EST'
    $pubdate = $item.pubDate
    $pubdate = $pubdate.Replace("EDT", "-4")
    $pubdate = $pubdate.Replace("EST", "-5")
    $pubdate = $pubdate.Replace("PDT", "-7")
    $pubdate = $pubdate.Replace("PST", "-8")
    
    $lastPost = [DateTime]::Parse($pubdate)
    
    if ($lastPost -lt $monthsAgo)
    {
      Write-Warning "No Posts in $($months) months from $($feedTitle)..."
      Write-Warning "Last Post on $($lastPost.ToLongDateString())."
    }
  }
}
