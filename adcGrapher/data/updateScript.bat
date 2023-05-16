@echo off
echo Updating app...
timeout /t 2
cd %~dp0
%~dp07z.exe x -y "%~dp0..\adcGrapher*.zip" -o%~dp0..\
IF %ERRORLEVEL% EQU 0 call :next_step

echo An error has ocurred
pause
EXIT /B 1

:next_step
echo Removing temp files...
del /q %~dp0..\adcGrapher*.zip
echo  Starting the app...
START "" /D "%~dp0..\" adcGrapher.exe
EXIT /B 0