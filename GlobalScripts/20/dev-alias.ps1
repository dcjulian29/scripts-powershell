function kvs { Stop-Process -ProcessName devenv }
function aia { Get-ChildItem | ?{ $_.Extension -eq ".dll" } | %{ Assembly-Info $_ } }
