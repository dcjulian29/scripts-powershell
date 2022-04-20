---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Get-PowershellVerbs.md
schema: 2.0.0
---

# Get-PowershellVerbs

## SYNOPSIS

Return a list of Approved Powershell Verbs.

## SYNTAX

```powershell
Get-PowershellVerbs [<CommonParameters>]
```

## DESCRIPTION

The Get-PowershellVerbs returns the list of approved verbs in the current Powershell session.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PowershellVerbs

Verb        AliasPrefix Group          Description
----        ----------- -----          -----------
Add         a           Common         Adds a resource to a container, or attaches an item to another item
Approve     ap          Lifecycle      Confirms or agrees to the status of a resource or process
Assert      as          Lifecycle      Affirms the state of a resource
Backup      ba          Data           Stores data by replicating it
Block       bl          Security       Restricts access to a resource
Build       bd          Lifecycle      Creates an artifact (usually a binary or document) out of some set of input files (usually s…
Checkpoint  ch          Data           Creates a snapshot of the current state of the data or of its configuration
Clear       cl          Common         Removes all the resources from a container but does not delete the container
Close       cs          Common         Changes the state of a resource to make it inaccessible, unavailable, or unusable
Compare     cr          Data           Evaluates the data from one resource against the data from another resource
Complete    cmp         Lifecycle      Concludes an operation

...

Use         u           Other          Uses or includes a resource to do something
Wait        w           Lifecycle      Pauses an operation until a specified event occurs
Watch       wc          Common         Continually inspects or monitors a resource for changes
Write       wr          Communications Adds information to a target
```

This example shows the current approved verbs that can be used for Powershell cmdlets.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
