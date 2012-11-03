function Get-WebcastsFromRSS
{
  param
  (
    [Parameter(ValueFromPipeline=$True)][String]$rssUrl,
    [String]$baseDirectory = $pwd.Path,
    [Bool]$downloadFiles = $true
  )

  $destinationFolder = $baseDirectory + "\_download"
  $dat = $baseDirectory + "\webcasts.dat"
  $ignoreFile = $baseDirectory + "\webcasts.ignore"

  Load-Assembly "System.Web"

  if (test-path $dat)
  {
    $enclosureHashes = Import-CSV $dat
  }
  else
  {
    $enclosureHashes = @()
  }
  
  if (test-path $ignoreFile)
  {
    $ignores = Import-CSV $ignoreFile
  }
  else
  {
    $ignores = @()
  }

  $client = New-Object Net.WebClient

  ""
  "------------------------------------------------------------------------------------"
  "Opening: $rssUrl"  
  $response = $client.DownloadString($rssUrl)
  $feed = [xml]$response.Substring($response.IndexOf('<'))
  $feedTitle = $feed.rss.channel.title
  
  "Feed Title: $feedTitle..."
  
  $feed.rss.channel.item | foreach `
  {
    ""
    $itemTitle = $_.title
    "Item: $itemTitle"

    $ignoreThis = $false
    $ignores | foreach `
    {
      if ($feedTitle -eq $_.feed)
      {
        if ($itemTitle -match $_.expression)
        {
          "  Ignoring this item..."
          $ignoreThis = $true
        }
      }    
    }
    
    if (-not $ignoreThis)
    {
      $enclosure = $_.enclosure
      
      if (([string]$enclosure.url).length -gt 0) 
      {
        # sometimes items have a non-parsable 'EDT' as part of pubdate 
        $pubdate = [DateTime]::Parse($_.pubdate.Replace("EDT", "-4"))
        $title = $_.title
        $enclosureUrl = $enclosure.url
        $enclosureUrl = $enclosureUrl.substring($enclosureUrl.indexof("http"))
        $enclosureUrl = new-object Uri($enclosureUrl)
        $fileName = $enclosureUrl.Segments[-1]
        $filePath = (join-path $destinationFolder $filename)
        $prehash = $feedTitle + $title + $enclosureUrl
        $hash = Get-Hash $prehash
        
        "Enclosure: $filename"
        if (($enclosureHashes | Where-Object { $_.hash -eq $hash } | Count-Object) -eq 0)
        {
          # Do not download a webcast if the file already exists.
          if ((-not (test-path ($filePath))))
          {
            if ($downloadFiles)
            {
              C:\bin\webcast-download $enclosure.url $destinationFolder
            }
          }
          
          if ((-not $downloadFiles) -or (test-path ([Web.HttpUtility]::UrlDecode($filePath))))
          {
            $ob = New-Object PSObject `
              | Add-Member -MemberType NoteProperty -Name "pubdate" -Value $pubdate -PassThru `
              | Add-Member -MemberType NoteProperty -Name "title" -Value $title -PassThru `
              | Add-Member -Membertype NoteProperty -Name "file" -Value $fileName -PassThru `
              | Add-Member -Membertype NoteProperty -Name "feed" -Value $feedTitle -PassThru `
              | Add-Member -MemberType NoteProperty -Name "hash" -Value $hash -PassThru
            $newHashes = @()
            if ($enclosureHashes.length -gt 0)
            {
              $newHashes += $enclosureHashes | select *
            }
            
            $newHashes += $ob | select *
            $newHashes | Export-CSV $dat -Force
            $enclosureHashes = $newHashes
          }        
        }
      }
    }
  } 
  ""
}

