$script:DefaultFolders = ""
$script:Namespace = ""

Function Get-Outlook {
     Add-type -Assembly "Microsoft.Office.Interop.Outlook" | Out-Null

     $script:DefaultFolders = "Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
     $outlook = New-Object -ComObject Outlook.Application
     $script:Namespace = $outlook.GetNameSpace("MAPI")
}

Function Get-OutlookCalendar {
      <#
       .Synopsis
        This function returns appointment items from default Outlook profile
       .Example
        Get-OutlookCalendar |
        where-object { $_.start -gt [datetime]"5/10/2011" -AND $_.start -lt `
        [datetime]"5/17/2011" } | sort-object Duration
        Displays subject, start, duration and location for all appointments that
        occur between 5/10/11 and 5/17/11 and sorts by duration of the appointment.
     #Requires -Version 2.0
     #>

     Get-Outlook

     $folder = $script:Namespace.getDefaultFolder($script:DefaultFolders::olFolderCalendar)
     $folder.items | Select-Object -Property Subject, AllDayEvent, Start, End, Duration, Location, Body
}

Function Get-UpcomingAppointments {
    param (
        [Int] $Days = 7,
        [DateTime] $Start = [DateTime]::Now ,
        [DateTime] $End   = [DateTime]::Now.AddDays($Days)
    )

    $appointments = Get-OutlookCalendar | Sort-Object Start | `
        Where-Object { ($_.End -ge $Start.ToString("g")) -and ($_.Start -le $End.ToString("g")) }

    foreach ($appt in $appointments) {

        $time = ""

        if (([DateTime]$appt.Start - [DateTime]$appt.End).Days -eq "-1") {
            $time = "All Day"
        } else {
            $time = "{0:hh:mmtt} - {1:hh:mmtt}" -f [DateTime]$appt.Start, [DateTime]$appt.End
        }
        
        $hash = @{
            DayOfWeek = "{0:ddd}" -f [DateTime]$appt.Start
            Date = "{0:yyyy-MM-dd}" -f [DateTime]$appt.Start
            Time = $time
            Subject = $appt.Subject
        }
        
        New-Object PSObject -Property $hash          
    }
}

Function Get-OutlookCalendarForGmail {
    param (
        [Int] $Days = 90,
        [DateTime] $Start = [DateTime]::Now ,
        [DateTime] $End   = [DateTime]::Now.AddDays($Days),
        [string]$Path
    )

    $appointments = Get-OutlookCalendar | Sort-Object Start | `
        Where-Object { ($_.End -ge $Start.ToString("g")) -and ($_.Start -le $End.ToString("g")) }

    foreach ($appt in $appointments) {
        $hash = @{
            Subject = $appt.Subject
            "Start Date" = "{0:MM/dd/yyyy}" -f [DateTime]$appt.Start
            "Start Time" = "{0:hh:mmtt}" -f [DateTime]$appt.Start
            "End Date" = "{0:MM/dd/yyyy}" -f [DateTime]$appt.End
            "End Time" = "{0:hh:mmtt}" -f [DateTime]$appt.End
            "All Day Event" = $appt.AllDayEvent
            Description = $appt.Body
            Location = $appt.Location
        }

        New-Object PSObject -Property $hash          
    }
}

Export-ModuleMember Get-OutlookCalendar
Export-ModuleMember Get-UpcomingAppointments
Export-ModuleMember Get-OutlookCalendarForGmail