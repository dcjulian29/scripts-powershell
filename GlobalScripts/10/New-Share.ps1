Function New-Share
{
  param
  (
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No folder name specified")]
    [string]$folderName,

    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No share name specified")]
    [string]$shareName,

    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No description specified")]
    [string]$description
  )

  $error.clear()
  
  if (!(Test-Path $folderName))
  {
    Write-Error "$($folderName) does not exists..."
  }
  else
  {

    if (!(Get-WMIObject Win32_share -filter "name='$shareName'"))
    {
      $trustee = ([WMIClass] "Win32_Trustee").CreateInstance()
      $trustee.Name = "EVERYONE"
      $trustee.Domain = $Null
      $trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

      $ace = ([WMIClass] "Win32_ACE").CreateInstance()
      $ace.AccessMask = 2032127
      $ace.AceFlags = 3
      $ace.AceType = 0
      $ace.Trustee = $trustee

      $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
      $sd.DACL += $ace.psObject.baseobject 

      $shares = [WMICLASS]"WIN32_Share"
      $params =  $shares.psbase.GetMethodParameters("Create")
      
      $params.Access = $sd
      $params.Description = $description
      $params.MaximumAllowed = $Null
      $params.Name = $shareName
      $params.Password = $Null
      $params.Path = $folderName
      $params.Type = [uint32]0
      
      $r = $shares.PSBase.InvokeMethod("Create", $params, $Null)
      
      if ($r.ReturnValue -eq 0)
      {
        Write-Host "Share $($shareName) created at $($folderName)..."
      }
      else 
      {
        Write-Error "Error creating share $($shareName)..."
      }
    }
    else
    {
      Write-Warning "Share $($shareName) already exists..."
    }
  }
}
