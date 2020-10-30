@echo off
cd %1
set LUA_PATH=%1\scripts\?.lua;%1\test\?.lua
lua %2