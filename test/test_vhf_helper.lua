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

local vhfHelper = dofile("scripts/vhf_helper.lua")

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
	flyWithLuaStub.datarefs = {}
	flyWithLuaStub.datarefs[self.Constants.firstComFreq] = {
		type = flyWithLuaStub.Constants.DatarefTypeInteger,
		localVariableAccessType = flyWithLuaStub.Constants.AccessTypeHandleOnly,
		data = self.Constants.initialComFrequency
	}
	flyWithLuaStub.datarefs[self.Constants.secondComFreq] = {
		type = flyWithLuaStub.Constants.DatarefTypeInteger,
		localVariableAccessType = flyWithLuaStub.Constants.AccessTypeHandleOnly,
		data = self.Constants.initialComFrequency
	}

	vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
end

function TestVhfHelperDatarefHandling:testTwoIndependentInterchangeFrequenciesAreDefinedCorrectly()
	local f1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local f2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]

	luaUnit.assertEquals(f1.localVariableAccessType, flyWithLuaStub.Constants.AccessTypeWritable)
	luaUnit.assertEquals(f2.localVariableAccessType, flyWithLuaStub.Constants.AccessTypeWritable)

	luaUnit.assertNotNil(f1.localVariableName)
	luaUnit.assertNotNil(f2.localVariableName)

	luaUnit.assertNotEquals(f1.localVariableName, f2.localVariableName)
end

function TestVhfHelperDatarefHandling:testTwoIndependentComFrequenciesAreDefinedCorrectly()
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	luaUnit.assertNotNil(c1.localVariableName)
	luaUnit.assertNotNil(c2.localVariableName)

	luaUnit.assertEquals(c1.localVariableAccessType, flyWithLuaStub.Constants.AccessTypeReadable)
	luaUnit.assertEquals(c2.localVariableAccessType, flyWithLuaStub.Constants.AccessTypeReadable)

	luaUnit.assertNotEquals(c1.localVariableName, c2.localVariableName)
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
	flyWithLuaStub:writeDatarefValueToLocalVariable(self.Constants.firstInterchangeFreq)

	flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(i1.data, newFrequency)
	luaUnit.assertEquals(c1.data, newFrequency)
end

local runner = luaUnit.LuaUnit.new()
runner:setOutputType("text", nil)
os.exit(runner:runSuite())
