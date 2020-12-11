local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")
local LuaPlatform = require("lua_platform")

local Utilities = require("vr-radio-helper.shared_components.utilities")
os.execute("mkdir TEMP\\TEST_RUN\\vr_radio_helper_data")

Utilities.copyBinaryFile(
    SCRIPT_DIRECTORY .. "../../scripts/vr_radio_helper_data/radar_plane.png",
    SCRIPT_DIRECTORY .. "vr_radio_helper_data/radar_plane.png"
)
Utilities.copyBinaryFile(
    SCRIPT_DIRECTORY .. "../../scripts/vr_radio_helper_data/radar_station.png",
    SCRIPT_DIRECTORY .. "vr_radio_helper_data/radar_station.png"
)

local vhfHelper = dofile("scripts/vhf_helper.lua")

flyWithLuaStub:suppressLogMessagesContaining(
    {
        "VR Radio Helper: Using '",
        "Plane Compatibility: ",
        "Speaking string=",
        "VR Radio Helper: Saving configuration",
        "InitializationItem name="
    }
)

require("shared_components.test_suite")

require("test_vatsim_data")
require("multicrew.test_multicrew")
require("test_speak_nato")
require("test_public_interface")
require("test_high_level_behaviour")
require("test_datarefs")
require("test_input_validation")
require("test_interchange_linked_dataref")
require("test_radar")

KNOWN_ISSUE(
    "VR Radio Helper",
    "The dot right next to the FlyWithLua macro will not disappear when the window is closed, only when clicking the macro again.",
    "Use the TogglePanel command (and map it to a key) instead of the macro.",
    {"FlyWithLua macro"}
)

TRACK_ISSUE(
    "X-Plane",
    "X-Plane does not let mouse clicks through to windows that do not yet have the focus.",
    "Mention that this is a known issue."
)
KNOWN_ISSUE(
    "VR Radio Helper",
    "When interacting with other 3D panels and returning to the VR Radio Helper panel, the first click is ignored.",
    "Click at least once anywhere into the panel and then use it normally.",
    {"X-Plane"}
)
