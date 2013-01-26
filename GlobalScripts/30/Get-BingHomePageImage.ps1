function Get-BingHomePageImage(
  [String]$destinationFolder = "$($env:Home)\SkyDrive\Wallpapers\Bing")
{

  $url = 'http://www.bing.com/HPImageArchive.aspx?format=js&n=10&mkt=en-us'

  (Invoke-RestMethod $url).images | foreach `
  {
    $imageUrl = "http://www.bing.com" + $_.url

    $uri = new-object Uri($imageUrl)
    $filename = (join-path $destinationFolder $uri.Segments[-1])

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
}
