@echo off

"%USERPROFILE%\scoop\shims\realpath.exe" %* | sed "s/\//\\/g"
