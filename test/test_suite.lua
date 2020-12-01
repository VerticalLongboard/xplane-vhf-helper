local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local vhfHelper = dofile("scripts/vhf_helper.lua")

flyWithLuaStub:suppressLogMessagesContaining(
    {
        "VR Radio Helper: Using '",
        "Plane Compatibility: ",
        "Speaking string=",
        "VR Radio Helper: Saving configuration"
    }
)

require("shared_components.test_suite")

require("test_station_info")
require("multicrew.test_multicrew")
require("test_speak_nato")
require("test_public_interface")
require("test_datarefs")
require("test_input_validation")
require("test_high_level_behaviour")
require("test_interchange_linked_dataref")

KNOWN_ISSUE(
    "VR Radio Helper",
    "The dot right next to the FlyWithLua macro will not disappear when the window is closed, only when clicking the macro again.",
    "Use the TogglePanel command (and map it to a key) instead of the macro.",
    {"FlyWithLua macro"}
)

KNOWN_ISSUE(
    "VR Radio Helper",
    "When restarting FlyWithLua, ATC information is not immediately shown because the download in Vatsimbrief Helper has not yet finished.",
    "Use the Refresh button in the side panel to refresh ATC data manually once.",
    {"Vatsimbrief Helper", "ATC"}
)
