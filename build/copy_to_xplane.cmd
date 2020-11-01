@echo off
call .\build\configure_environment.cmd

copy /Y %1 "%XPLANE_PATH%\Resources\plugins\FlyWithLua\Scripts"