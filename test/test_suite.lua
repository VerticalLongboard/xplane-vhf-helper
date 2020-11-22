local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local IssueTracker = require("issue_tracker")
local issueTracker = IssueTracker:new()
TRACK_ISSUE = function(component, description, workaround)
    issueTracker:post(component, description, workaround)
end

local vhfHelper = dofile("scripts/vhf_helper.lua")

flyWithLuaStub:suppressLogMessagesContaining({"VR Radio Helper: Using '"})

require("test_speak_nato")
require("test_public_interface")
require("test_dataref_handling")
require("test_configuration")
require("test_input_validation")
require("test_high_level_behaviour")
require("test_interchange_linked_dataref")

issueTracker:declareLinkedKnownIssue(
    "VR Radio Helper",
    "Quickly closing and opening a panel again leads to the panel closing itself after about second.",
    {"float_wnd_set_visible", "close function is called asynchronously"}
)

issueTracker:print()
