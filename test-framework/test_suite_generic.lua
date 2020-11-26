TRACK_ISSUE = TRACK_ISSUE or function(component, description, workaround)
    end

require("shared_components.lua_compatibility_wrapper")
local issueTracker = require("issue_tracker")
TRACK_ISSUE(
    "Lua",
    "Switching from Lua 5.1 to 5.4 broke compatibility with LuaUnit and almost any table.insert call. Also, loadstring does not longer exist.",
    "Redefine basic language features according to current interpreter version."
)

local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

-- Put your tests in test/test_suite.lua
require("test_suite")

local runner = luaUnit.LuaUnit.new()
-- runner:setOutput(luaUnitOutput.ColorText)
runner:setOutput(luaUnitOutput.ColorTap)
local runnerResult = runner:runSuite()
issueTracker:printSummary()
if (os.getenv("ISSUE_TRACKER_TRIGGER_ALL_ISSUES") ~= nil) then
    issueTracker:printAllIssues()
end
os.exit(runnerResult)
