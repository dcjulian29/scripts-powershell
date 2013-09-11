function go-dev 
{
  if (Test-Path "C:\dev")
  {
    Set-Location C:\dev
  }
  else
  {
    Write-Error "C:\Dev does not exist... Maybe a more specific development directory is needed?"
  }
}

function dev-fei 
{
  if (Test-Path "D:\fei\dev")
  {
    Set-Location D:\fei\dev
  }
  else
  {
    Write-Error "FEi Development Directory does not exist..."
  }
}

function dev-jcog
{
  if (Test-Path "D:\jcog\dev")
  {
    Set-Location D:\jcog\dev
  }
  else
  {
    Write-Error "JCoG Development Directory does not exist..."
  }
}

function dev-jnet
{
  if (Test-Path "D:\jnet\dev")
  {
    Set-Location D:\jnet\dev
  }
  else
  {
    Write-Error "JNet Development Directory does not exist..."
  }
}

function dev-wiki
{
  if (Test-Path "D:\jnet\wiki")
  {
    Set-Location D:\jnet\wiki
  }
  else
  {
    Write-Error "JNet Wiki Directory does not exist..."
  }
}

function kvs { Stop-Process -ProcessName devenv }

function aia { Get-ChildItem | ?{ $_.Extension -eq ".dll" } | %{ Assembly-Info $_ } }