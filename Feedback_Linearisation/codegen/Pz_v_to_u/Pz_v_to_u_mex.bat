@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2019b
call "C:\Program Files\MATLAB\R2019b\sys\lcc64\lcc64\mex\lcc64opts.bat"
"C:\Program Files\MATLAB\R2019b\toolbox\shared\coder\ninja\win64\ninja.exe" -v %*
