"%ProgramFiles%\Oracle\VirtualBox\VBoxManage.exe" storageattach "MyBootLoader" --storagectl "IDE" --port 0 --device 0 --type hdd --medium "%~dp0..\os-image.vdi"
if NOT ["%ERRORLEVEL%"]==["0"] (pause)
exit