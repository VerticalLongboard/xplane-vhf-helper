local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local vhfHelper = dofile("scripts/vhf_helper.lua")
flyWithLuaStub:suppressLogMessagesBeginningWith("VHF Helper: VHF Helper using '")

require("test_public_interface")
require("test_dataref_handling")
require("test_configuration")
require("test_frequency_validation")
require("test_high_level_behaviour")
require("test_interchange_linked_dataref")
