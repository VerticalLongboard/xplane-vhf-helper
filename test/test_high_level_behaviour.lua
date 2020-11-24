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
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")

TestHighLevelBehaviour = {
	Constants = {
		comPanelButtonTitle = "COM",
		navPanelButtonTitle = "NAV",
		transponderPanelButtonTitle = "XPDR",
		SidePanelButtonTitle = ">"
	}
}

function TestHighLevelBehaviour:_pressButton(buttonTitle)
	imguiStub:pressButtonProgrammaticallyOnce(buttonTitle)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasButtonPressed())
end

function TestHighLevelBehaviour:_assertStringShowsUp(str)
	imguiStub:keepALookOutForString(str)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestHighLevelBehaviour:_enterNumberViaUserInterface(numberString)
	for i = 1, #numberString do
		self:_pressButton(numberString:sub(i, i))
	end
end

function TestHighLevelBehaviour:_switchToOtherFrequency(vhfNumber, linkedDatarefId, newFrequencyString)
	self:_enterNumberViaUserInterface(newFrequencyString)

	local d = flyWithLuaStub.datarefs[linkedDatarefId]

	luaUnit.assertNotEquals(d.data, tonumber(newFrequencyString))
	self:_pressButton("<" .. tostring(vhfNumber) .. ">")
	luaUnit.assertEquals(d.data, tonumber(newFrequencyString))
end

function TestHighLevelBehaviour:_switchToOtherTransponder(linkedDatarefId, newTransponderString)
	self:_enterNumberViaUserInterface(newTransponderString)

	local d = flyWithLuaStub.datarefs[linkedDatarefId]

	luaUnit.assertNotEquals(d.data, tonumber(newTransponderString))
	self:_pressButton("<X>")
	luaUnit.assertEquals(d.data, tonumber(newTransponderString))
end

function TestHighLevelBehaviour:createInternalDatarefsAndBootstrap()
	flyWithLuaStub:reset()
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.firstComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialCom1Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.secondComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialCom2Frequency
	)

	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.firstNavFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialNav1Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.secondNavFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialNav2Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.transponderCode,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialTransponderCode
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.transponderMode,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialTransponderMode
	)

	local vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:bootstrapAllMacros()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
end

TRACK_ISSUE("Test", "Missing test for: Default visibility set to true in INI shows window")
function TestHighLevelBehaviour:setUp()
	self:createInternalDatarefsAndBootstrap()
	flyWithLuaStub:activateMacro(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName, true)
end

function TestHighLevelBehaviour:testClosingThePanelChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "yes")
	flyWithLuaStub:closeWindowByTitle(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName)
	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "no")
end

function TestHighLevelBehaviour:testDeactivatingTheScriptChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "yes")
	flyWithLuaStub:activateAllMacros(false)
	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "no")
end

function TestHighLevelBehaviour:testCurrentComFrequenciesAreShownSomewhere()
	local freqAsString = tostring(TestDatarefs.Constants.initialCom1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)

	freqAsString = tostring(TestDatarefs.Constants.initialCom2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)
end

function TestHighLevelBehaviour:testEnteredComStringIsShownSomewhere()
	local freqString = "132805"
	self:_enterNumberViaUserInterface(freqString)
	self:_assertStringShowsUp(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
end

function TestHighLevelBehaviour:testSwitchingComDoesSwitch()
	local freqString = "129725"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondComFreq, freqString)

	local freqString2 = "122650"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondComFreq, freqString2)
end

function TestHighLevelBehaviour:testCurrentNavFrequenciesAreShownSomewhere()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	local freqAsString = tostring(TestDatarefs.Constants.initialNav1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)

	freqAsString = tostring(TestDatarefs.Constants.initialNav2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)
end

function TestHighLevelBehaviour:testEnteredNavStringIsShownSomewhere()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	local freqString = "111800"
	self:_enterNumberViaUserInterface(freqString)
	self:_assertStringShowsUp(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
end

function TestHighLevelBehaviour:testSwitchingNavDoesSwitch()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	local freqString = "10965"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondNavFreq, freqString)

	local freqString2 = "11535"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondNavFreq, freqString2)
end

function TestHighLevelBehaviour:testSwitchingTransponderDoesSwitch()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	local transponderString = "4066"
	self:_switchToOtherTransponder(TestDatarefs.Constants.transponderCode, transponderString)

	local transponderString2 = "1000"
	self:_switchToOtherTransponder(TestDatarefs.Constants.transponderCode, transponderString2)
end

function TestHighLevelBehaviour:testCurrentTransponderCodeIsShownSomewhere()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	local codeString = tostring(TestDatarefs.Constants.initialTransponderCode)
	self:_assertStringShowsUp(codeString)
end

function TestHighLevelBehaviour:testTogglePanelCommandTogglesPanel()
	local toggleWindowCommandName = "FlyWithLua/VR Radio Helper/TogglePanel"
	local windowTitle = vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName

	luaUnit.assertIsTrue(flyWithLuaStub:isWindowOpen(flyWithLuaStub:getWindowByTitle(windowTitle)))
	flyWithLuaStub:executeCommand(toggleWindowCommandName)
	flyWithLuaStub:cleanupBeforeRunningNextFrame()
	luaUnit.assertNil(flyWithLuaStub:getWindowByTitle(windowTitle))
	flyWithLuaStub:executeCommand(toggleWindowCommandName)
	flyWithLuaStub:cleanupBeforeRunningNextFrame()
	luaUnit.assertIsTrue(flyWithLuaStub:isWindowOpen(flyWithLuaStub:getWindowByTitle(windowTitle)))
end

function TestHighLevelBehaviour:testTransmoderModeIsSwitched()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	local tm = flyWithLuaStub.datarefs[TestDatarefs.Constants.transponderMode]
	luaUnit.assertEquals(tm.data, TestDatarefs.Constants.initialTransponderMode)

	local newMode = 0
	self:_pressButton(vhfHelperPackageExport.test.transponderModeToDescriptor[newMode + 1])
	luaUnit.assertEquals(tm.data, newMode)

	local newMode2 = 3
	self:_pressButton(vhfHelperPackageExport.test.transponderModeToDescriptor[newMode2 + 1])
	luaUnit.assertEquals(tm.data, newMode2)
end

function TestHighLevelBehaviour:testSideWindowOpensAndRendersAfterOneFrame()
	self:_pressButton(self.Constants.SidePanelButtonTitle)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isWindowOpen(
			flyWithLuaStub:getWindowByTitle(vhfHelperPackageExport.test.vhfHelperSideWindow.Constants.defaultWindowName)
		)
	)
end

function TestHighLevelBehaviour:testSideWindowMulticrewSupportShowsUpInDefaultState()
	self:_pressButton(self.Constants.SidePanelButtonTitle)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertStringShowsUp("SmartCopilot is not set up for your current aircraft.\nSetup SmartCopilot first.")
end
