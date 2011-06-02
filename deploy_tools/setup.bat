@echo off
call gem_installer.bat
echo Setting-up cmap-eval path.
call setx PATH "%PATH%;%~dp0"
echo You can now execute cmap-eval by typing
echo cmap-eval -h
pause