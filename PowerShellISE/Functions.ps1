Function Add-Help
{
 $helpText = @"
<#
.SYNOPSIS
    What does this do? 

.PARAMETER param1 
    What is param1?

.PARAMETER param2 
    What is param2?

.NOTES
    NAME: $($psISE.CurrentFile.DisplayName)
    AUTHOR: $env:username
    LASTEDIT: $(Get-Date)
    KEYWORDS:

.LINK
    http://julianscorner.com

.EXAMPLE     
    '12345' | THIS-FUNCTION -param1 180   
    Describe what this example accomplishes 
       
.EXAMPLE     
    THIS-FUNCTION -param2 @("text1","text2") -param1 180   
    Describe what this example accomplishes 

#Requires -Version 2.0
#>

"@
 $psise.CurrentFile.Editor.InsertText($helpText)
}

Function Add-FunctionTemplate
{
  $text1 = @"
Function THIS-FUNCTION
{
"@
  $text2 = @"
	[CmdletBinding()]
  param
  (
    [Parameter(Mandatory = `$true,
               ValueFromPipeline = `$true)]   
    [array]`$param1,                                   
    [Parameter(Mandatory = `$true)]   
    [int]`$param2
  )   
  BEGIN
  {
    # This block is used to provide optional one-time pre-processing for the function.
    # PowerShell uses the code in this block one time for each instance of the function in the pipeline.
  }
  PROCESS
  {
    # This block is used to provide record-by-record processing for the function.
    # This block might be used any number of times, or not at all, depending on the input to the function.
    # For example, if the function is the first command in the pipeline, the Process block will be used one time.
    # If the function is not the first command in the pipeline, the Process block is used one time for every
    # input that the function receives from the pipeline.
    # If there is no pipeline input, the Process block is not used.
  }
  END
  {
    # This block is used to provide optional one-time post-processing for the function.
  } 
}
"@
 $psise.CurrentFile.Editor.InsertText($text1)
 Add-Help
 $psise.CurrentFile.Editor.InsertText($text2)
}

Function Remove-AliasFromScript
{
  Get-Alias | 
    Select-Object Name, Definition | 
    ForEach-Object -Begin { $a = @{} } -Process {$a.Add($_.Name, $_.Definition)} -End {}

  $b = $errors = $null
  $b = $psISE.CurrentFile.Editor.Text

  [system.management.automation.psparser]::Tokenize($b,[ref]$errors) |
    Where-Object { $_.Type -eq "command" } |
      ForEach-Object `
      {
        if ($a.($_.Content))
        {
          $b = $b -replace
            ('(?<=(\W|\b|^))' + [regex]::Escape($_.content) + '(?=(\W|\b|$))'),
              $a.($_.content)
        }
      }

  $ScriptWithoutAliases = $psISE.CurrentPowerShellTab.Files.Add()
  $ScriptWithoutAliases.Editor.Text = $b
  $ScriptWithoutAliases.Editor.SetCaretPosition(1,1)
  $ScriptWithoutAliases.Editor.EnsureVisible(1)  
}

Function Replace-SpacesWithTabs
{
  param
  (
    [int]$spaces = 2
  ) 
  
  $tab = "`t"
  $space = " " * $spaces
  $text = $psISE.CurrentFile.Editor.Text

  $newText = ""
  
  foreach ($line in $text -split [Environment]::NewLine)
  {
    if ($line -match "\S")
    {
      $pos = $line.IndexOf($Matches[0])
      $indentation = $line.SubString(0, $pos)
      $remainder = $line.SubString($pos)
      
      $replaced = $indentation -replace $space, $tab
      
      $newText += $replaced + $remainder + [Environment]::NewLine
    }
    else
    {
      $newText += $line + [Environment]::NewLine
    }

    $psISE.CurrentFile.Editor.Text  = $newText
  }
}

Function Replace-TabsWithSpaces
{
  param
  (
    [int]$spaces = 2
  )   
  
  $tab = "`t"
  $space = " " * $spaces
  $text = $psISE.CurrentFile.Editor.Text

  $newText = ""
  
  foreach ($line in $text -split [Environment]::NewLine)
  {
    if ($line -match "\S")
    {
      $pos = $line.IndexOf($Matches[0])
      $indentation = $line.SubString(0, $pos)
      $remainder = $line.SubString($pos)
      
      $replaced = $indentation -replace $tab, $space
      
      $newText += $replaced + $remainder + [Environment]::NewLine
    }
    else
    {
      $newText += $line + [Environment]::NewLine
    }

    $psISE.CurrentFile.Editor.Text  = $newText
  }
}

Function Indent-SelectedText
{
  param
  (
    [int]$spaces = 2
  )
  
  $tab = " " * $space
  $text = $psISE.CurrentFile.Editor.SelectedText

  $newText = ""
  
  foreach ($line in $text -split [Environment]::NewLine)
  {
    $newText += $tab + $line + [Environment]::NewLine
  }

   $psISE.CurrentFile.Editor.InsertText($newText)
}

Function Add-RemarkedText
{
<#
.SYNOPSIS
    This function will add a remark character # to selected text in the ISE.
    These are comment characters, and is great when you want to comment out
    a section of PowerShell code.

.NOTES
    NAME:  Add-RemarkedText
    AUTHOR: ed wilson, msft
    LASTEDIT: 05/16/2013
    KEYWORDS: Windows PowerShell ISE, Scripting Techniques

.LINK
     http://www.ScriptingGuys.com

#Requires -Version 2.0
#>
  $text = $psISE.CurrentFile.Editor.SelectedText

  foreach ($l in $text -Split [Environment]::NewLine)
  {
   $newText += "{0}{1}" -f ("#" + $l),[Environment]::NewLine
  }

  $psISE.CurrentFile.Editor.InsertText($newText)
}

Function Remove-RemarkedText
{
<#
.SYNOPSIS
    This function will remove a remark character # to selected text in the ISE.
    These are comment characters, and is great when you want to clean up a
    previously commentted out section of PowerShell code.

.NOTES
    NAME:  Add-RemarkedText
    AUTHOR: ed wilson, msft
    LASTEDIT: 05/16/2013
    KEYWORDS: Windows PowerShell ISE, Scripting Techniques

.LINK
     http://www.ScriptingGuys.com

#Requires -Version 2.0
#>
  $text = $psISE.CurrentFile.Editor.SelectedText

  foreach ($l in $text -Split [Environment]::NewLine)
  {
    $newText += "{0}{1}" -f ($l -Replace '#',''),[Environment]::NewLine
  }

  $psISE.CurrentFile.Editor.InsertText($newText)
}
