# Administrative Functions


function elevate
{
  $file, [string]$arguments = $args;
  $psi = new-object System.Diagnostics.ProcessStartInfo $file;
  $psi.Arguments = $arguments;
  $psi.Verb = "runas";
  [System.Diagnostics.Process]::Start($psi);
}

Set-Alias sudo elevate

function run-as
{
  $file, [string]$arguments = $args;
  $psi = new-object System.Diagnostics.ProcessStartInfo $file;
  $psi.Arguments = $arguments;
  $psi.Verb = "runasuser";
  [System.Diagnostics.Process]::Start($psi);
}



