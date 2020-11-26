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
local Globals = require("vhf_helper.globals")
TRACK_ISSUE(
    "Lua",
    "Switching from Lua 5.1 to 5.4 broke compatibility with LuaUnit and almost any table.insert call. Also, loadstring does not longer exist.",
    "Redefine basic language features according to current interpreter version."
)
require("shared_components.lua_compatibility_wrapper")

Globals.requireAllAndBootstrap({"vhf_helper.public_interface"})
Globals.requireAllAndBootstrap(
    {
        -- "vhf_helper.state.notifications",
        "vhf_helper.state.validation",
        "vhf_helper.state.datarefs",
        "vhf_helper.state.panels",
        "vhf_helper.state.config",
        "vhf_helper.singletons.compatibility_manager",
        "vhf_helper.singletons.multicrew_manager",
        "vhf_helper.singletons.main_window",
        "vhf_helper.singletons.side_window",
        "vhf_helper.singletons.loop"
    }
)
Globals.requireAllAndBootstrap({"vhf_helper.package_export"})

TRACK_ISSUE(
    "FlyWithLua",
    "When returning anything besides nothing, FlyWithLua does not expose global fields to other scripts.",
    "Return default module and use package export script to expose globals instead."
)
return
