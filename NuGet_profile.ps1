################################################################################
# This profile is loaded when the 
# nuget.exe Package Manager Console "host" is executed.
################################################################################

. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" NuGet

function prompt()
{
	"§->";
}
