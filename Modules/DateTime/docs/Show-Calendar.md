---
external help file: DateTime-help.xml
Module Name: DateTime
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/DateTime/docs/Show-Calendar.md
schema: 2.0.0
---

# Show-Calendar

## SYNOPSIS

Displays a visual representation of a calendar.

## SYNTAX

```powershell
Show-Calendar [[-Start] <DateTime>] [[-End] <DateTime>] [[-FirstDayOfWeek] <Object>]
 [[-HighlightDay] <Int32[]>] [[-HighlightDate] <String[]>]
```

## DESCRIPTION
Displays a visual representation of a calendar.
This function supports multiple months
and lets you highlight specific date ranges or days.

## EXAMPLES

### EXAMPLE 1

```Powershell
# Show a default display of this month.
Show-Calendar
```

### EXAMPLE 2

```powershell
# Display a date range.
Show-Calendar -Start "March, 2022" -End "May, 2022"
```

### EXAMPLE 3

```powershell
# Highlight a range of days.
Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "2022-12-25"
```

## PARAMETERS

### -Start

The first month to display.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: [DateTime]::Today
Accept pipeline input: False
Accept wildcard characters: False
```

### -End

The last month to display.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $start
Accept pipeline input: False
Accept wildcard characters: False
```

### -FirstDayOfWeek

The day of the month on which the week begins.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HighlightDay

Specific days (numbered) to highlight.
Used for date ranges like (25..31).
Date ranges are specified by the Windows PowerShell range syntax.
These dates are
enclosed in square brackets.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HighlightDate

Specific days (named) to highlight.
These dates are surrounded by asterisks.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: [DateTime]::Today.ToString('yyyy-MM-dd')
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
