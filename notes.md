# My Notes

- A cmdlet is a .NET class written in C# or other language and contained in a DLL (i.e. in a binary module).
- A function is specified directly in PowerShell in a script, script module or at the command line.
- A module manifest may include both script and binary modules so the manifest needs to be able to export both cmdlets and functions.

## Import Module into Current Session

```powershell
Import-Module "./$((Get-Item $PWD.Path).BaseName).psd1" -Verbose -Force
```

```powershell
idpdm $((Get-Item $PWD.Path).BaseName)
```

## Generate Markdown Documentation

```powershell
New-MarkdownHelp -Module "$((Get-Item $PWD.Path).BaseName)" -OutputFolder .\docs -WithModulePage

Move-Item -Path "docs/$((Get-Item $PWD.Path).BaseName).md" -Destination "./README.md"

(Get-ChildItem ./docs/*.md -Recurse).FullName | ForEach-Object {
  $text = ""
  $file = (Split-Path -Leaf $_ )
  Get-Content $_ | ForEach-Object {
    $text += $_ -creplace "^online version:$", "online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/$((Get-Item $PWD.Path).BaseName)/docs/$file"
    $text += [System.Environment]::NewLine
  }

  Set-Content -Path $_ -Value $text
  Write-Output "Processed '$file'"
}
```

- Update and correct each markdown file with online links and remove the extra stuff at bottom.
- Add Examples.
- Don't generate the external help until this is complete.

## Generate/Update Powershell Documentation

```powershell
New-ExternalHelp .\docs -OutputPath en-US\ -Force
```

## Updating the Markdown Documentation

```powershell
Remove-Module "./$((Get-Item $PWD.Path).BaseName)" -Force -ErrorAction Continue
Import-Module "./$((Get-Item $PWD.Path).BaseName).psd1" -Verbose -Force
Update-MarkdownHelp .\docs
```
