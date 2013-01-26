$script:TOOLSDIR = "C:\bin\sysinternals"

function Download-Command()
{
	param([string]$command = $null);

	if ( $command )
	{
		$url = "http://live.sysinternals.com/$command";
		$target = "$($script:TOOLSDIR)\$command";
    
    Get-WebFile $url $target
	}
}

function Update-Command()
{
	param([string]$command);

	if ( $command )
	{
		pushd $script:TOOLSDIR;
		$full_command = "$($script:TOOLSDIR)\$command";
		
		if ( [System.IO.File]::Exists($full_command) )
		{
			Remove-Item $command;
		}
		
		Download-Command $command;
		
		popd;
	}
}

function Update-Commands()
{
	param([string[]]$commands);

	if ( $commands )
	{
		foreach ($command in $commands)
		{
			Update-Command $command;
		}
	}
}

function Get-Commands()
{
	$commands = @();

	Write-Host "Querying commands from live.sysinternals.com...";
	
	$wc = New-Object System.Net.WebClient;
	$site = $wc.DownloadString('http://live.sysinternals.com');
	[regex]$re = ">[a-zA-Z0-9._-]*</A>";
	$found_matches = $re.Matches($site);
	foreach ($found_match in $found_matches)
	{
		$cmd = $found_match.Value.Substring(1, $found_match.Value.Length-5);
		$do_download = $false;
		switch -wildcard ($cmd.ToLower())
		{
			"*.exe" { $do_download = $true; }
			"*.dll" { $do_download = $true; }
			"*.chm" { $do_download = $true; }
			"*.hlp" { $do_download = $true; }
			"*.sys" { $do_download = $true; }
		}
		if ( $do_download )
		{
			$commands += @($cmd);
		}
	}
	$commands;
}

function Update-SysInternals
{
  if ( ![System.IO.Directory]::Exists($script:TOOLSDIR) )
  {
    mkdir $script:TOOLSDIR;
  }

  if ( $null -eq $commands )
  {
    $commands = Get-Commands;
  }

  Update-Commands $commands;
}