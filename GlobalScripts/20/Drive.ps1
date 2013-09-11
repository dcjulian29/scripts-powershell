Function List-UsbDrives
{
  Get-WmiObject Win32_DiskDrive `
    | where { $_.InterfaceType -eq 'USB' } `
    | Select-Object DeviceId, InterfaceType, Status, SerialNumber, Model, Size, MediaType
}

Function List-FixedDrives
{
  Get-WmiObject Win32_DiskDrive `
    | where { $_.InterfaceType -ne 'USB' } `
    | Select-Object DeviceId, InterfaceType, Status, SerialNumber, Model, Size, MediaType
}

Function List-Drives
{
  Get-WmiObject Win32_LogicalDisk `
    | Select-Object DeviceID, ProviderName, Size, FreeSpace `
    | Format-List
}