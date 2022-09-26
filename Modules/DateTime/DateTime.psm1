function Show-Calendar {
  [Alias("calendar")]
  param (
    [DateTime] $Start = [DateTime]::Today,
    [DateTime] $End = $Start,
    $FirstDayOfWeek,
    [int[]] $HighlightDay,
    [string[]] $HighlightDate = [DateTime]::Today.ToString('yyyy-MM-dd')
  )

  $Start = New-Object DateTime $Start.Year,$Start.Month,1
  $End   = New-Object DateTime $End.Year  ,$End.Month  ,1
  [DateTime[]] $HighlightDate = [DateTime[]] $HighlightDate
  $dateTimeFormat  = (Get-Culture).DateTimeFormat

  if ($FirstDayOfWeek) {
      $dateTimeFormat.FirstDayOfWeek = $FirstDayOfWeek
  }

  $currentDay = $Start

  while($Start -le $End) {
    while($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek) {
      $currentDay = $currentDay.AddDays(-1)
    }

    $currentWeek = New-Object PsObject
    $dayNames = @()
    $weeks = @()

    while(($currentDay -lt $Start.AddMonths(1)) -or
        ($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek)) {
      $dayName = "{0:ddd}" -f $currentDay
      if ($dayNames -notcontains $dayName) {
        $dayNames += $dayName
      }

      $displayDay = " {0,2} " -f $currentDay.Day

      if ($HighlightDate) {
        $compareDate = New-Object DateTime $currentDay.Year, $currentDay.Month,
          $currentDay.Day
        if ($HighlightDate -contains $compareDate) {
          $displayDay = "*" + ("{0,2}" -f $currentDay.Day) + "*"
        }
      }

      if ($HighlightDay -and ($HighlightDay[0] -eq $currentDay.Day)) {
        $displayDay = "[" + ("{0,2}" -f $currentDay.Day) + "]"
          $null,$HighlightDay = $HighlightDay
      }

      $currentWeek | Add-Member NoteProperty $dayName $displayDay

      $currentDay = $currentDay.AddDays(1)

      if ($currentDay.DayOfWeek -eq $dateTimeFormat.FirstDayOfWeek) {
        $weeks += $currentWeek
        $currentWeek = New-Object PsObject
      }
    }

    $calendar = $weeks | Format-Table $dayNames -AutoSize | Out-String
    $width = ($calendar.Split("`n") | Measure-Object -Maximum Length).Maximum
    $header = "{0:MMMM yyyy}" -f $Start
    $padding = " " * (($width - $header.Length) / 2)
    $displayCalendar = " `n" + $padding + $header + "`n " + $calendar
    $displayCalendar.TrimEnd()

    $Start = $Start.AddMonths(1)
  }
}
