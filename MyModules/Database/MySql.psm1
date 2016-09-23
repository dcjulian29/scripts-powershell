$mysqlPath = Find-ProgramFiles 'MySQL\MySQL Server 5.5\bin\mysql.exe'

function mysql()
{
  & $mysqlPath "--defaults-file=C:\ProgramData\MySQL\MySQL Server 5.5\my.ini" "-uroot" "-p"
}

function Start-MySql()
{
  & $mysqlPath Start
}

function Stop-MySql()
{
  & $mysqlPath Stop
}
