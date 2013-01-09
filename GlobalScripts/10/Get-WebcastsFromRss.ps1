function Get-WebcastsFromRSS
{
  param
  (
    [Parameter(ValueFromPipeline=$True)][String]$rssUrl,
    [String]$baseDirectory = $pwd.Path,
    [Bool]$downloadFiles = $true,
    [Bool]$useDirectories = $false
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
    "... $itemTitle ..."

    $ignoreThis = $false
    $ignores | foreach `
    {
      if ($feedTitle -eq $_.feed)
      {
        if ($itemTitle -match $_.expression)
        {
          "    Ignoring this item..."
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
        $fileName = [Web.HttpUtility]::UrlDecode($enclosureUrl.Segments[-1])
        $prehash = $feedTitle + $title + $enclosureUrl
        $hash = Get-Hash $prehash
        
        "    Enclosure: $filename"
        if (($enclosureHashes | Where-Object { $_.hash -eq $hash } | Count-Object) -eq 0)
        {
          # Do not download a webcast if the file already exists.
          if ($downloadFiles)
          {
            if ($useDirectories)
            {
              $destination = $baseDirectory + "\" + $feedTitle
            }
            else
            {
              $destination = $destinationFolder
            }

            $src = $enclosure.url
            $dst = $destination + "\" + $fileName
            if ((-not (test-path ($destination))))
            {
              mkdir $destination
            }
            
            ""
            C:\bin\network\wget\wget.exe "$src" -O "$dst" --continue --tries=10 --restrict-file-names=windows
          }

          if ((-not $downloadFiles) -or (test-path ($dst)))
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
            "... Recording Download ..."
            $newHashes | Export-CSV $dat -Force
            $enclosureHashes = $newHashes
          }
          else
          {
            "... Download Failed ..."
          }
        }
      }
    }
  } 
  ""
}

