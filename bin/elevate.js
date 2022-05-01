// elevate.js -- runs target command line elevated
if (WScript.Arguments.Length >= 1)
{
  application = WScript.Arguments(0);
  arguments = "";
  
  for (Index = 1; Index < WScript.arguments.Length; Index += 1) 
  {
    if (Index > 1)
    {
      arguments += " ";
    }
    
    var current = WScript.arguments(Index);

    if (current.indexOf(' ') !== -1)
    {
      current = '"' + current + '"'
    }
    
    arguments += current;
  }

  var app = new ActiveXObject("Shell.application")
  
  app.ShellExecute(application, arguments, "", "runas");
}
else 
{
  WScript.Echo("Usage: elevate application arguments");
}
