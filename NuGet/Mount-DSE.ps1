$local:driveData = DATA { @'
	commands = dte:/commands
	commandBars = dte:/commandBars
	windows = dte:/windows
	tasks = dte:/tasks
	projects = dte:/solution/projects
'@ | ConvertFrom-StringData };

Write-Debug "Mounting Common DTE Drives ..."

$local:driveData.keys | foreach `
{
  $local:path = $local:driveData[$_];
  $local:driveName = ( $_ + ':' );
	
  #Write-Verbose "Mounting drive ${_}: at path $local:path";
  #New-PSDrive -name $_ -PSProvider PSDTE -Root $path | Out-Null;
	
  #Write-Verbose "Defining shortcut function ${_}:";
  #New-Item -Path function: -Name $local:driveName -Value "Set-Location $($local:driveName)" | Out-Null;
};

#New-Item -Path function: -Name "dte:" -Value "Set-Location dte:" | Out-Null;
