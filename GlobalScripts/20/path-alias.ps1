function path-cygwin { $env:Path = "C:\cygwin\bin;$($env:Path)" }
function path-mongo { $env:Path = "C:\Program Files\MongoDB\bin;$($env:Path)" }
function path-nodejs { $env:Path = "$($env:PF32)\nodejs;$($env:Path)" }

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
