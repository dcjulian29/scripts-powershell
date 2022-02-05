---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-Dive.md
schema: 2.0.0
---

# Invoke-Dive

## SYNOPSIS

Invoke a tool for exploring a docker image

## SYNTAX

```powershell
Invoke-Dive
```

## DESCRIPTION

The Invoke-Dive function is a wrapper around a tool for exploring a docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image. Additionally the tool estimates the amount of wasted space and identifies the offending files from the image.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-Dive
No image argument given
```

This example invokes the Dive tool.

## PARAMETERS

- Anything after the function name is passed unmodified as arguments.
