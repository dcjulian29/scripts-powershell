var wsh = new ActiveXObject("WScript.Shell");
var program = WScript.Arguments(0);

wsh.Run(program, 0, false);
