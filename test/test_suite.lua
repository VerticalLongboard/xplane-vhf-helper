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
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local vhfHelper = dofile("scripts/vhf_helper.lua")
flyWithLuaStub:suppressLogMessagesBeginningWith("VHF Helper: VHF Helper using '")

require("test_vhf_helper_public_interface")
require("test_vhf_helper_dataref_handling")
require("test_vhf_helper_configuration")
require("test_vhf_helper_frequency_validation")
require("test_vhf_helper_high_level_behaviour")

local runner = luaUnit.LuaUnit.new()
runner:setOutputType("text", nil)
os.exit(runner:runSuite())