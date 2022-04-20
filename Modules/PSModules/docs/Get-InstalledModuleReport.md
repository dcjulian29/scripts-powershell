---
external help file: PSModules-help.xml
Module Name: PSModules
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSModules/docs/Get-InstalledModuleReport.md
schema: 2.0.0
---

# Get-InstalledModuleReport

## SYNOPSIS

Report the installed modules decending by published date.

## SYNTAX

```powershell
Get-InstalledModuleReport [<CommonParameters>]
```

## DESCRIPTION

The Get-InstalledModuleReport command reports the installed modules decending by published date.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-InstalledModuleReport -Name Powershell
Name                                  Version      PublishedDate         RepositorySourceLocation
----                                  -------      -------------         ------------------------
GitlabCli                             1.59.0       4/14/2022 3:36:15 PM  https://www.powershellgallery.com/api/v2
MicrosoftTeams                        4.2.0        4/13/2022 2:56:54 PM  https://www.powershellgallery.com/api/v2
Posh-ACME                             4.14.0       4/13/2022 5:33:10 AM  https://www.powershellgallery.com/api/v2
AzureDevOps                           2020.7.24.1  4/9/2022 9:11:17 PM   https://www.myget.org/F/dcjulian29-powershe...
PSWriteHTML                           0.0.173      4/9/2022 12:12:30 PM  https://www.powershellgallery.com/api/v2
Lability                              0.21.1       4/1/2022 11:48:18 AM  https://www.powershellgallery.com/api/v2
PSRule                                2.0.0        3/25/2022 12:23:51 AM https://www.powershellgallery.com/api/v2
VSTeam                                7.6.1        3/7/2022 4:28:20 PM   https://www.powershellgallery.com/api/v2
PowershellForDocker                   2202.7.1     3/3/2022 3:34:22 PM   https://www.myget.org/F/dcjulian29-powershe...
Microsoft.PowerShell.SecretManagement 1.1.2        1/27/2022 6:16:33 PM  https://www.powershellgallery.com/api/v2
Microsoft.PowerShell.SecretStore      1.0.6        1/27/2022 6:13:46 PM  https://www.powershellgallery.com/api/v2
VirtualDevelopment                    2201.19.1    1/25/2022 4:20:39 AM  https://www.myget.org/F/dcjulian29-powershe...
WebCredential                         2201.17.1    1/18/2022 5:14:10 AM  https://www.myget.org/F/dcjulian29-powershe...
VirtualBaseDisk                       2201.17.1    1/18/2022 5:13:53 AM  https://www.myget.org/F/dcjulian29-powershe...
PSParseHTML                           0.0.20       1/16/2022 8:21:28 PM  https://www.powershellgallery.com/api/v2
PSWriteWord                           1.1.14       1/11/2022 5:15:37 PM  https://www.powershellgallery.com/api/v2
Grok                                  1.1.0        1/9/2022 12:54:48 AM  https://www.powershellgallery.com/api/v2
7Zip4Powershell                       2.1.0        1/2/2022 3:55:38 PM   https://www.powershellgallery.com/api/v2
PSWritePDF                            0.0.18       12/23/2021 8:48:56 AM https://www.powershellgallery.com/api/v2
PSScriptAnalyzer                      1.20.0       8/24/2021 7:43:49 PM  https://www.powershellgallery.com/api/v2
Trackyon.Utils                        0.2.1        8/8/2021 9:21:13 PM   https://www.powershellgallery.com/api/v2
platyPS                               0.14.2       7/2/2021 10:53:28 PM  https://www.powershellgallery.com/api/v2
PSSlack                               1.0.6        7/1/2021 12:46:21 AM  https://www.powershellgallery.com/api/v2
Microsoft.PowerShell.ConsoleGuiTools  0.6.2        4/29/2021 9:23:48 PM  https://www.powershellgallery.com/api/v2
PowerShellForGitHub                   0.16.0       1/5/2021 8:03:58 PM   https://www.powershellgallery.com/api/v2
BurntToast                            0.8.5        12/30/2020 9:00:59 PM https://www.powershellgallery.com/api/v2
PSWriteExcel                          0.1.12       11/21/2020 8:58:14 AM https://www.powershellgallery.com/api/v2
PowerShellGet                         2.2.5        9/22/2020 10:42:00 PM https://www.powershellgallery.com/api/v2
AnsibleVault                          0.3.0        12/2/2019 9:41:11 AM  https://www.powershellgallery.com/api/v2
PsIni                                 3.1.2        4/24/2019 8:45:08 AM  https://www.powershellgallery.com/api/v2
SHiPS                                 0.8.1        9/21/2018 7:08:52 PM  https://www.powershellgallery.com/api/v2
```

This example reports the installed modules decending by published date.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
