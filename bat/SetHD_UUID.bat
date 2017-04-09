"%ProgramFiles%\Oracle\VirtualBox\VBoxManage.exe" internalcommands sethduuid "%~dp0\..\os-image.vdi"
if NOT ["%ERRORLEVEL%"]==["0"] (pause)
exit