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

flyWithLuaStub:suppressLogMessagesBeginningWith("VHF Helper using '")

TestVhfHelperFrequencyValidation = {}

function TestVhfHelperFrequencyValidation:testAlmostValidFrequencyIsConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.validateFullFrequencyString("123.420"), "123.425")
end

function TestVhfHelperFrequencyValidation:testObviouslyInvalidFrequencyIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.validateFullFrequencyString("923x420"), nil)
end

function TestVhfHelperFrequencyValidation:testSomeRandomStringIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.validateFullFrequencyString("__1l]"), nil)
end

function TestVhfHelperFrequencyValidation:testNilOrEmptyStringIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.validateFullFrequencyString(nil), nil)
	luaUnit.assertEquals(vhfHelperPackageExport.test.validateFullFrequencyString(""), nil)
end

function TestVhfHelperFrequencyValidation:testFullFrequencyIsNotChangedByAutocompletion()
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123.500"), "123.500")
end

function TestVhfHelperFrequencyValidation:testFiveDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123.42"), "123.425")
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123.43"), "123.430")
end

function TestVhfHelperFrequencyValidation:testFourDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123.4"), "123.400")
end

function TestVhfHelperFrequencyValidation:testLessThanFourDigitFrequencyIsNotAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123."), "123.")
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("123"), "123")
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("12"), "12")
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString("1"), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.autocompleteFrequencyString(""), "")
end

function TestVhfHelperFrequencyValidation:testValidFrequencyCanBeEntered()
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("", 1), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("1", 2), "2")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("12", 4), "4")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("124", 5), "5")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("124.5", 7), "7")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("124.57", 5), "5")
end

function TestVhfHelperFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("", 1), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("1", 4), "_")
end

function TestVhfHelperFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("", 1), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("1", 3), "3")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("13", 6), "6")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("136", 9), "9")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("136.9", 8), "_")
end

TestVhfHelperPublicInterface = {}

function TestVhfHelperPublicInterface:setUp()
	vhfHelperPackageExport.test.activatePublicInterface()
	self.activeInterface = VHFHelperPublicInterface
	luaUnit.assertNotNil(self.activeInterface)
end

function TestVhfHelperPublicInterface:tearDown()
	vhfHelperPackageExport.test.deactivatePublicInterface()
	self.activeInterface = VHFHelperPublicInterface
	luaUnit.assertNil(self.activeInterface)
end

function TestVhfHelperPublicInterface:testFixInterface()
	luaUnit.assertNotNil(self.activeInterface.enterFrequencyProgrammaticallyAsString)
	luaUnit.assertNotNil(self.activeInterface.isCurrentlyTunedIn)
	luaUnit.assertNotNil(self.activeInterface.isCurrentlyEntered)
	luaUnit.assertNotNil(self.activeInterface.isValidFrequency)
end

function TestVhfHelperPublicInterface:testEnteringProgrammaticallyReportsEnteredCurrently()
	local enterFreq = "132.850"
	luaUnit.assertEquals(self.activeInterface.enterFrequencyProgrammaticallyAsString(enterFreq), enterFreq)
	luaUnit.assertIsTrue(self.activeInterface.isCurrentlyEntered(enterFreq))
end

TestVhfHelperDatarefHandling = {
	Constants = {
		firstComFreq = "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
		secondComFreq = "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
		firstInterchangeFreq = "VHFHelper/InterchangeVHF1Frequency",
		secondInterchangeFreq = "VHFHelper/InterchangeVHF2Frequency",
		initialComFrequency = 118000
	}
}

function TestVhfHelperDatarefHandling:setUp()
	flyWithLuaStub:reset()
	flyWithLuaStub:createSharedDatarefHandle(
		TestVhfHelperDatarefHandling.Constants.firstComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		self.Constants.initialComFrequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestVhfHelperDatarefHandling.Constants.secondComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		self.Constants.initialComFrequency
	)

	vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
end

function TestVhfHelperDatarefHandling:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(d1, d2, expectedAccessType)
	local variableCount = 0
	local lastVariableName = nil
	for localVariableName, localVariable in pairs(d1.localVariables) do
		luaUnit.assertEquals(localVariable.accessType, expectedAccessType)
		variableCount = variableCount + 1
		lastVariableName = localVariableName
	end

	for localVariableName, localVariable in pairs(d2.localVariables) do
		luaUnit.assertEquals(localVariable.accessType, expectedAccessType)
		variableCount = variableCount + 1

		luaUnit.assertNotEquals(localVariableName, lastVariableName)
	end

	luaUnit.assertTrue(variableCount == 2)
end

function TestVhfHelperDatarefHandling:testTwoIndependentInterchangeFrequenciesAreDefinedCorrectly()
	local f1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local f2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(f1, f2, flyWithLuaStub.Constants.AccessTypeWritable)
end

function TestVhfHelperDatarefHandling:testTwoIndependentComFrequenciesAreDefinedCorrectly()
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(c1, c2, flyWithLuaStub.Constants.AccessTypeReadable)
end

function TestVhfHelperDatarefHandling:testInternalFrequencyChangeUpdatesBothComAndInterchange()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]

	luaUnit.assertEquals(c1.data, i1.data)
	oldFrequency = c1.data
	local newFrequency = 133600
	luaUnit.assertNotEquals(oldFrequency, newFrequency)

	vhfHelperPackageExport.test.setPlaneVHFFrequency(1, newFrequency)

	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(i1.data, newFrequency)
	luaUnit.assertEquals(c1.data, newFrequency)
end

function TestVhfHelperDatarefHandling:testExternalChangeViaInterchangeUpdatesLocalComFrequencies()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]

	luaUnit.assertEquals(c1.data, i1.data)
	oldFrequency = c1.data
	local newFrequency = 123800
	luaUnit.assertNotEquals(oldFrequency, newFrequency)

	i1.data = newFrequency
	flyWithLuaStub:writeDatarefValueToLocalVariables(self.Constants.firstInterchangeFreq)

	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(i1.data, newFrequency)
	luaUnit.assertEquals(c1.data, newFrequency)
end

function TestVhfHelperDatarefHandling:testInternalChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225
	vhfHelperPackageExport.test.setPlaneVHFFrequency(2, newFrequency)

	for f = 1, 10 do
		flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end

function TestVhfHelperDatarefHandling:testExternalChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225
	i2.data = newFrequency
	flyWithLuaStub:writeDatarefValueToLocalVariables(self.Constants.secondInterchangeFreq)

	for f = 1, 10 do
		flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end

TestVhfHelperConfiguration = {}

function TestVhfHelperConfiguration:testConfigurationValuesAreSetAndRetrievedCorrectly()
	local testConfig = Configuration:new(SCRIPT_DIRECTORY .. "test_vhf_helper.ini")

	local section = "GeneralTest"
	local key = "MajorFailureReason"
	local value = "Random"

	luaUnit.assertIsNil(testConfig:getValue(section, key, nil))

	testConfig:setValue(section, key, value)

	local defaultValue = "ArbitraryButNotRandom"
	luaUnit.assertEquals(testConfig:getValue(section, key, defaultValue), value)
end

TestVhfHelperHighLevelBehaviour = {
	Constants = {
		initialCom1Frequency = 119000,
		initialCom2Frequency = 124300
	}
}

function TestVhfHelperHighLevelBehaviour:_enterFrequencyViaUserInterface(freqString)
	for i = 1, #freqString do
		imguiStub:pressButtonProgrammaticallyOnce(freqString:sub(i, i))
		flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
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
	flyWithLuaStub:bootstrapScriptUserInterface()
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
end

function TestVhfHelperHighLevelBehaviour:testClosingThePanelChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(flyWithLuaStub.userInterfaceIsActive)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")

	for _, window in pairs(flyWithLuaStub.windows) do
		flyWithLuaStub:closeWindow(window)
	end

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestVhfHelperHighLevelBehaviour:testDeactivatingTheScriptChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(flyWithLuaStub.userInterfaceIsActive)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "visible")

	flyWithLuaStub:shutdownScriptUserInterface()

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowVisibility, "hidden")
end

function TestVhfHelperHighLevelBehaviour:testPanelIsVisibleByDefault()
	luaUnit.assertIsTrue(flyWithLuaStub.userInterfaceIsActive)
end

function TestVhfHelperHighLevelBehaviour:testCurrentComFrequenciesAreShownSomewhere()
	local freqAsString = tostring(self.Constants.initialCom1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	imguiStub:keepALookOutForString(fullFrequencyString)
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())

	freqAsString = tostring(self.Constants.initialCom2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	imguiStub:keepALookOutForString(fullFrequencyString)
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestVhfHelperHighLevelBehaviour:testEnteredStringIsShownSomewhere()
	local freqString = "132805"
	self:_enterFrequencyViaUserInterface(freqString)

	imguiStub:keepALookOutForString(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestVhfHelperHighLevelBehaviour:testSwitchingToAFrequencyDoesSwitch()
	local freqString = "129725"
	self:_enterFrequencyViaUserInterface(freqString)

	local c2 = flyWithLuaStub.datarefs[TestVhfHelperDatarefHandling.Constants.secondComFreq]

	luaUnit.assertNotEquals(c2.data, tonumber(freq))

	imguiStub:pressButtonProgrammaticallyOnce("<2>")
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasButtonPressed())

	luaUnit.assertEquals(c2.data, tonumber(freqString))
end

local runner = luaUnit.LuaUnit.new()
runner:setOutputType("text", nil)
os.exit(runner:runSuite())
