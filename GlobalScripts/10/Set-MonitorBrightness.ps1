function Set-MonitorBrightness(
  [Parameter(ValueFromPipeline=$True)][ValidateRange(0,100)][int]$brightness)
{
  $mymonitor = Get-WmiObject -Namespace root\wmi -Class WmiMonitorBrightnessMethods
  $mymonitor.wmisetbrightness(5,$brightness)
}