local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local vhfHelper = dofile("scripts/vhf_helper.lua")

flyWithLuaStub:suppressLogMessagesContaining({"VR Radio Helper: Using '"})

require("test_speak_nato")
require("test_public_interface")
require("test_datarefs")
require("test_configuration")
require("test_input_validation")
require("test_high_level_behaviour")
require("test_interchange_linked_dataref")

KNOWN_ISSUE(
    "VR Radio Helper",
    "Quickly closing and opening a panel again leads to the panel closing itself after about second.",
    "Don't close and open the panel too quickly.",
    {"float_wnd_set_visible", "close function is called asynchronously"}
)

KNOWN_ISSUE(
    "VR Radio Helper",
    "The dot right next to the FlyWithLua macro will not disappear when the window is closed, only when clicking the macro again.",
    "Use the TogglePanel command (and map it to a key) instead of the macro.",
    {"FlyWithLua macro"}
)
