--[[

MIT License

Copyright (c) 2020 VerticalLongboard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]
local LuaPlatform = require("lua_platform")
local Globals = require("vr-radio-helper.globals")
TRACK_ISSUE(
    "Lua",
    "Switching from Lua 5.1 to 5.4 broke compatibility with almost any table.insert call. Also, loadstring got renamed.",
    "Redefine basic language features according to current interpreter version."
)
Globals.requireAllAndBootstrapInOrder(
    {
        "vr-radio-helper.public_interface",
        "vr-radio-helper.state.config",
        "vr-radio-helper.state.notifications",
        "vr-radio-helper.state.validation",
        "vr-radio-helper.state.datarefs",
        "vr-radio-helper.state.station_info",
        "vr-radio-helper.state.panels",
        "vr-radio-helper.singletons.compatibility_manager",
        "vr-radio-helper.singletons.multicrew_manager",
        "vr-radio-helper.singletons.main_window",
        "vr-radio-helper.singletons.side_window",
        "vr-radio-helper.singletons.loop",
        "vr-radio-helper.package_export"
    }
)

TRACK_ISSUE(
    "FlyWithLua",
    "When returning anything besides nothing, FlyWithLua does not expose global fields to other scripts.",
    "Return default module and use package export script to expose globals instead."
)
return
