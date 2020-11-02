@echo off
call .\build\configure_environment.cmd

copy /a .\scripts\*.* "%XPLANE_PATH%\Resources\plugins\FlyWithLua\Scripts"
copy /a .\modules\*.* "%XPLANE_PATH%\Resources\plugins\FlyWithLua\Modules"