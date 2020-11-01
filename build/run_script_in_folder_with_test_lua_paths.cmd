@echo off
call .\build\configure_environment.cmd

cd %1
set LUA_PATH=%1\scripts\?.lua;%1\test\?.lua
"%LUA_EXECUTABLE_PATH%\lua.exe" %2