start %comspec% /c ""C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86 && cd .. && nmake all"
if NOT ["%ERRORLEVEL%"]==["0"] (pause)
exit