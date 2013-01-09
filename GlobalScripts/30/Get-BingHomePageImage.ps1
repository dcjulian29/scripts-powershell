function Get-BingHomePageImage(
  [String]$destinationFolder = "$($env:Home)\SkyDrive\Wallpapers\Bing")
{
  $client = New-Object Net.WebClient
  
  $feed = [xml]$client.DownloadString("http://www.bing.com/HPImageArchive.aspx?format=rss&n=1&mkt=en-us")
  
  $pic = $feed.rss.channel.item.link
  $enclosureUrl = "http://www.bing.com" + $pic    
  $uri = new-object Uri($enclosureUrl)
  $filename = (join-path $destinationFolder (get-date).ToString("yyyyMMdd")) + ".jpg"

  if ((-not (test-path ($fileName))))
  {
    try
    {
      Get-WebFile $uri.AbsoluteUri $filename
    }
    catch [Exception]
    {
      $_.Exception.Message
    }
  } 
}
