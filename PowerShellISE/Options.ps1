$psISE.Options.FontName = 'Consolas'
$psISE.Options.FontSize = 11
$psISE.Options.SelectedScriptPaneState = 'Top'
$psISE.Options.ShowOutlining = $true
$psISE.Options.ShowLineNumbers = $true
 
#$psISE.Options.RestoreDefaultTokenColors()

#Background 
$psISE.Options.ScriptPaneBackgroundColor = '#293134'

#Default Text Color 
$psISE.Options.TokenColors['Unknown'] = '#E0E2E4'

# Token Text Colors
$psISE.Options.TokenColors['Comment'] = '#66747B'
$psISE.Options.TokenColors['String'] = '#EC7600'
$psISE.Options.TokenColors['Number'] = '#FFCD22'
$psISE.Options.TokenColors['Variable'] = '#E0E2E4'
$psISE.Options.TokenColors['Operator'] = '#E8E2B7' 
$psISE.Options.TokenColors['Keyword'] = '#93C763'
$psISE.Options.TokenColors['Command'] = '#678CB1'

#Others Token Text Colors
$psISE.Options.TokenColors['CommandParameter'] = '#E0E2E4'    #  -name "computername"
                                                              #---^
$psISE.Options.TokenColors['CommandArgument'] = '#E0E2E4'     #  -name "computername"
                                                              #---------^
$psISE.Options.TokenColors['Member'] = '#E0E2E4'              #  $_.Name -eq $serviceName 
                                                              #------^
$psISE.Options.TokenColors['GroupEnd'] = '#E0E2E4'            # Opening Curly Brace or Parenthesis
$psISE.Options.TokenColors['GroupStart'] = '#E0E2E4'          # Closing Curly Brace or Parenthesis
$psISE.Options.TokenColors['Attribute'] = '#E0E2E4'           #  [Parameter(Mandatory = $true)]   
                                                              #----^
$psISE.Options.TokenColors['Type'] = '#E0E2E4'                #  [int]$param2
                                                              #----^
$psISE.Options.TokenColors['LineContinuation'] = '#E0E2E4'    #  Write-Host -Fore Yellow `
                                                              #--------------------------^
$psISE.Options.TokenColors['StatementSeparator'] = '#E0E2E4'  #  Write-Host ; Write-Host -Fore Yellow "Some Text"
                                                              #-------------^

#Console Window
$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
if ($principal.IsInRole("Administrators"))
{
  $psISE.Options.ConsolePaneBackgroundColor = 'DarkRed'
  $psISE.Options.ConsolePaneTextBackgroundColor = 'Transparent'
  $psISE.Options.ConsolePaneForegroundColor = 'Yellow'
}
else
{
  $psISE.Options.ConsolePaneBackgroundColor = 'DarkBlue'
  $psISE.Options.ConsolePaneTextBackgroundColor = 'Transparent'
  $psISE.Options.ConsolePaneForegroundColor = 'LightGray'
}
