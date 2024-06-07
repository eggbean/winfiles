set FSO = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "tpmiddle-rs.exe --sensitivity 9 --fn-lock", 0, False
Set WshShell = Nothing