@echo off
call .\build\configure_environment.cmd

%PACKETSENDER_EXECUTABLE% --ascii --udp localhost 49000 CMND\00FlyWithLua/debugging/reload_scripts\00
