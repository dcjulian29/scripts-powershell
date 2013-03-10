function dev-aamva { Set-Location D:\aamva\dev }
function dev-jcog { Set-Location D:\jcog\dev }
function dev-jnet { Set-Location D:\jnet\dev }
function dev-marriott { Set-Location D:\marriott\dev }

function kvs { Stop-Process -ProcessName devenv }

function aia { Get-ChildItem | ?{ $_.Extension -eq ".dll" } | %{ Assembly-Info $_ } }