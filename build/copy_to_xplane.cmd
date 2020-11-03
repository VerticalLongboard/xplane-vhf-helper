@echo off
call .\build\configure_environment.cmd

copy /Y .\scripts\*.* "%XPLANE_PATH%\Resources\plugins\FlyWithLua\Scripts"
copy /Y .\modules\*.* "%XPLANE_PATH%\Resources\plugins\FlyWithLua\Modules"