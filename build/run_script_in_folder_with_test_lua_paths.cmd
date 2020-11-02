@echo off
call .\build\configure_environment.cmd

cd %1
set LUA_PATH=%1\scripts\?.lua;%1\test\?.lua;%1\test-framework\?.lua
%LUA_EXECUTABLE% %2