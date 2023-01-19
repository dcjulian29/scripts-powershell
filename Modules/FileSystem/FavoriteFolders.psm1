$Global:GoDataDirectory = "$([Environment]::GetFolderPath('LocalApplicationData'))\Go-Shell\"
$Global:GoRememberFileName = "go-shell-remember-last.txt"
$Global:GoBookmarkFileName = "go-shell.txt"

$Script:DataFilePath = $Global:GoDataDirectory + $Global:GoBookmarkFileName
$Script:LastBookmarkPath = $Global:GoDataDirectory + $Global:GoRememberFileName
$Script:SetupDone = $false

function checkSetup {
  if ($Script:SetupDone) {
    return
  }

  $Script:DataFilePath = $Global:GoDataDirectory + $Global:GoBookmarkFileName
  $Script:LastBookmarkPath = $Global:GoDataDirectory + $Global:GoRememberFileName

  if (-not (Test-Path $Global:GoDataDirectory)) {
      New-Folder -Path $Global:GoDataDirectory
  }

  if (-not (Test-Path $Script:DataFilePath)) {
    Invoke-TouchFile -Path $Script:DataFilePath
  }

  if (-not (Test-Path $Script:LastBookmarkPath)) {
    Invoke-TouchFile -Path $Script:LastBookmarkPath
  }

  $Script:SetupDone = $true
}

#-----------------------------------------------------------------------------

function Add-FavoriteFolder {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Key,
    [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("PSPath", "SelectedPath")]
    [string] $Path = $PWD.Path,
    [switch] $Force
  )

  checkSetup

  if ((Get-FavoriteFolder $Key) -and (-not $Force)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Favorite Folder already exists! Use -Force to replace." `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "NewItemIOError" -ErrorCategory "ResourceExists"))
  }

  $Path = Resolve-FullPath $Path

  if (-not (Test-Path $Path -PathType Container)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Favorite Folder target does not exists!" `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "NewItemNotExists" -ErrorCategory "ObjectNotFound"))
  }

  $compositeKey = $key.ToLower() + "|" + $Path

  Write-Verbose "Composite Key: $compositeKey"

  Add-Content -value $compositeKey -Path $Script:DataFilePath
}

function Clear-FavoriteFolder {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param (
    [switch] $Force
   )

  checkSetup

  if ($PSCmdlet.ShouldProcess($Script:DataFilePath, "Clear all keys from database")) {
    if ($Force -or $PSCmdlet.ShouldContinue("Are you sure you want to clear the Favorite Folder database?", "Clear Database")) {
      Clear-Content $Script:DataFilePath
    }
  }
}

function Get-FavoriteFolder {
  [CmdletBinding()]
  param (
    [Parameter(Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [string] $Key
  )

  checkSetup

  $list = @()
  $content = Get-Content $Script:DataFilePath

  if ($content) {
    foreach ($item in $content) {
      Write-Verbose "item: $item"

      $kv = New-Object -TypeName PSObject

      $kv | Add-Member -MemberType NoteProperty -Name Key -Value $item.Split('|')[0]
      $kv | Add-Member -MemberType NoteProperty -Name Value -Value $item.Split('|')[1]

      $list += $kv
    }
  }

  if ($Key) {
      $list = $list | Where-Object { $_.Key -eq $Key }
  }

  return $list
}

function Push-FavoriteFolder {
  [CmdletBinding(DefaultParameterSetName="KeyOnly")]
  [Alias("gd")]
  param (
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="KeyOnly")]
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="KeyAndPath")]
    [Parameter(Mandatory=$true, Position=0, ParameterSetName="KeyAndAlias")]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter( {
      [OutputType([System.Management.Automation.CompletionResult])]
      param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)

      return (Get-FavoriteFolder).Key | Sort-Object `
        | Where-Object { $_ -ne $WordToComplete } | Where-Object { $_.StartsWith($WordToComplete) }
      } )]
    [string] $Key,

    [Parameter(Position=1, ParameterSetName="KeyAndPath")]
    [Parameter(Position=1, ParameterSetName="KeyAndAlias")]
    [ValidateNotNullOrEmpty()]
    [Alias("PSPath", "SelectedPath")]
    [string] $Path = $PWD.Path,

    [Parameter(ParameterSetName="KeyAndAlias")]
    [Alias("a")]
    [switch] $Add,

    [Parameter(ParameterSetName="KeyAndAlias")]
    [Alias("d")]
    [switch] $Delete,

    [Parameter(ParameterSetName="ClearAlias")]
    [Alias("c")]
    [switch] $Clear,

    [Parameter(ParameterSetName="KeyAndAlias")]
    [Alias("s")]
    [switch] $Show,

    [Parameter(ParameterSetName="ShowAllAlias")]
    [Alias("sa")]
    [switch] $ShowAll,

    [Parameter(ParameterSetName="LastAlias")]
    [Alias("l")]
    [switch] $Last
  )

  if ($Last) {             # -last or -l            Goes to the last used go-shell key.
    Push-LastFavoriteFolder
    return
  }

  if ($ShowAll) {          # -showAll or -sa        Show all the keys and values in the directory.
    Get-FavoriteFolder
    return
  }

  if ($Show) {             # -show or -s            Show the specific key and value.
    Get-FavoriteFolder $Key
    return
  }

  if ($Clear) {            # -clear or -c           Clears all the keys and values in the directory.
    Clear-FavoriteFolder
    return
  }

  if ($delete -or $d) {    # -delete or -d          Remove the given key from the directory.
    Remove-FavoriteFolder $Key
    return
  }

  if ($Add) {              # -add or -a             Adds the current directory.
    Add-FavoriteFolder
    return
  }

  checkSetup

  if (-not (Get-FavoriteFolder $Key)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Favorite Folder does not exists!" `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "ItemNotExists" -ErrorCategory "ObjectNotFound"))
  }

  $bookmark = (Get-FavoriteFolder $Key).Value
  $path = $Global:GoDataDirectory + $Global:GoRememberFileName

  if (Test-Path -Path $bookmark) {
    Clear-Content $Script:LastBookmarkPath
    Add-Content -Value $bookmark -Path $Script:LastBookmarkPath
    Set-Location $bookmark
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Favorite Folder target does not exists!" `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "PathNotExists" -ErrorCategory ResourceUnavailable))
  }
}

function Push-LastFavoriteFolder {
  [CmdletBinding()]
  param ( )

  checkSetup

  $path = $Global:GoDataDirectory + $Global:GoRememberFileName
  $content = Get-Content $path
  $last = ""

  $content | ForEach-Object { $last = $_ }

  if ($last) {
    if (Test-Path -Path $last) {
      Set-Location $last
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Favorite Folder target does not exists!" `
        -ExceptionType "System.IO.IOException" `
        -ErrorId "PathNotExists" -ErrorCategory ResourceUnavailable))
    }
  } else {
    Write-Warning "Last Favorite Folder bookmark isn't available."
  }
}

function Remove-FavoriteFolder {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param (
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $Key,
    [switch] $Force
  )

  checkSetup

  if (-not (Get-FavoriteFolder $Key)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Favorite Folder does not exists!" `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "ItemNotExists" -ErrorCategory "ObjectNotFound"))
  }

  if ($PSCmdlet.ShouldProcess($Script:DataFilePath, "Remove key '$Key' from database")) {
    if ($Force -or $PSCmdlet.ShouldContinue("Are you sure you want to delete '$Key' from the Favorite Folder database?", "Remove Key")) {
      $content = Get-Content $Script:DataFilePath
      $content = $content | Where-Object { $_ -notlike "$Key|*" }

      Clear-Content $Script:DataFilePath

      Add-Content -Value $content -Path $Script:DataFilePath
    }
  }
}
