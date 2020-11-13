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

TestVhfHelperHighLevelBehaviour = {
	Constants = {
		initialCom1Frequency = 119000,
		initialCom2Frequency = 124300
	}
}

function TestVhfHelperHighLevelBehaviour:_enterFrequencyViaUserInterface(freqString)
	for i = 1, #freqString do
		imguiStub:pressButtonProgrammaticallyOnce(freqString:sub(i, i))
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		luaUnit.assertTrue(imguiStub:wasButtonPressed())
	end
end

function TestVhfHelperHighLevelBehaviour:setUp()
	flyWithLuaStub:reset()
	flyWithLuaStub:createSharedDatarefHandle(
		TestVhfHelperDatarefHandling.Constants.firstComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		self.Constants.initialCom1Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestVhfHelperDatarefHandling.Constants.secondComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		self.Constants.initialCom2Frequency
	)

	vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:bootstrapAllMacros()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
end

function TestVhfHelperHighLevelBehaviour:testClosingThePanelChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")
	flyWithLuaStub:closeWindowByTitle(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName)
	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestVhfHelperHighLevelBehaviour:testDeactivatingTheScriptChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")

	flyWithLuaStub:activateAllMacros(false)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestVhfHelperHighLevelBehaviour:testPanelIsVisibleByDefault()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)
end

function TestVhfHelperHighLevelBehaviour:testCurrentComFrequenciesAreShownSomewhere()
	local freqAsString = tostring(self.Constants.initialCom1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	imguiStub:keepALookOutForString(fullFrequencyString)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())

	freqAsString = tostring(self.Constants.initialCom2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	imguiStub:keepALookOutForString(fullFrequencyString)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestVhfHelperHighLevelBehaviour:testEnteredStringIsShownSomewhere()
	local freqString = "132805"
	self:_enterFrequencyViaUserInterface(freqString)

	imguiStub:keepALookOutForString(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestVhfHelperHighLevelBehaviour:testSwitchingToAFrequencyDoesSwitch()
	local freqString = "129725"
	self:_enterFrequencyViaUserInterface(freqString)

	local c2 = flyWithLuaStub.datarefs[TestVhfHelperDatarefHandling.Constants.secondComFreq]

	luaUnit.assertNotEquals(c2.data, tonumber(freqString))

	imguiStub:pressButtonProgrammaticallyOnce("<2>")
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasButtonPressed())

	luaUnit.assertEquals(c2.data, tonumber(freqString))
end
