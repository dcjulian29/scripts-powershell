function Get-WallPapers
{
  $up = "$($env:Home)\Wallpapers\"
  @("http://themeserver.microsoft.com/default.aspx?p=Bing&c=Desktop&m=en-US",
    "http://themeserver.microsoft.com/default.aspx?p=Windows&c=Aqua&m=en-US",
    "http://themeserver.microsoft.com/default.aspx?p=Windows&c=Fauna&m=en-US",
    "http://themeserver.microsoft.com/default.aspx?p=Windows&c=Flora&m=en-US",
    "http://themeserver.microsoft.com/default.aspx?p=Windows&c=Insects&m=en-US",
    "http://themeserver.microsoft.com/default.aspx?p=Windows&c=LandScapes&m=en-US") | foreach `
    {
      Get-RssEnclosures $_ $up
    }
}
