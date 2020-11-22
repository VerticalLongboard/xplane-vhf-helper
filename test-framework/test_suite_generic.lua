local luaUnitOutput = require("luaunit_output")
local luaUnit = require("luaunit")
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

local IssueTracker = require("issue_tracker")
local issueTracker = IssueTracker:new()
TRACK_ISSUE = function(component, description, workaround)
    issueTracker:post(component, description, workaround)
end

KNOWN_ISSUE = function(newComponent, newDescription, blameStringList)
    issueTracker:declareLinkedKnownIssue(newComponent, newDescription, blameStringList)
end

-- Put your tests in test/test_suite.lua
require("test_suite")

local runner = luaUnit.LuaUnit.new()
-- runner:setOutput(luaUnitOutput.ColorText)
runner:setOutput(luaUnitOutput.ColorTap)
local runnerResult = runner:runSuite()
issueTracker:printSummary()
os.exit(runnerResult)
