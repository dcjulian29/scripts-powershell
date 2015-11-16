function path-cygwin { 
    if (Test-Path "C:\cygwin\bin")
    {
        $env:Path = "C:\cygwin\bin;$($env:Path)" 
    }
}

function path-mongo {
    if (Test-Path "C:\Program Files\MongoDB\bin")
    {
        $env:Path = "C:\Program Files\MongoDB\bin;$($env:Path)" 
    }

    if (Test-Path "C:\tools\apps\mongodb")
    {
        $env:Path = "C:\tools\apps\mongodb;$($env:Path)" 
    }
}

function path-nodejs {
    if (Test-Path "C:\Program Files\nodejs")
    {
        $env:Path = "C:\Program Files\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm;$($env:Path)" 
    }

    if (Test-Path "C:\Program Files (x86)\nodejs")
    {
        $env:Path = "C:\Program Files (x86)\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm;$($env:Path)" 
    }
}

function path-java 
{ 
  $java = ""

  if (Test-Path "C:\Program Files (x86)\Java\jre6")
  {
    $java = "C:\Program Files (x86)\Java\jre6"
  }

  if (Test-Path "C:\Program Files (x86)\Java\jre7")
  {
    $java = "C:\Program Files (x86)\Java\jre7"
  }

  if (Test-Path "C:\Program Files\Java\jre6")
  {
    $java = "C:\Program Files\Java\jre6"
  }

  if (Test-Path "C:\Program Files\Java\jre7")
  {
    $java = "C:\Program Files\Java\jre7"
  }

  if ($java.Length -gt 0)
  {
    $env:JAVA_HOME = $java
    $env:Path = "$java\bin;$($env:PATH)"    
  }
  else
  {
    Write-Error "Java Runtime Not Found!"
  }
}
