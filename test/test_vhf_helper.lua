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
function logMsg(stringToLog)
	print("TEST LOG: " .. stringToLog)
end

function create_command(commandName, readableCommandName, toggleExpressionName, something1, something2)
end

function add_macro(readableScriptName, activateExpression, deactivateExpression, activateOrDeactivate)
end

function define_shared_DataRef(globalDatarefIdName, datarefType)
end

function dataref(localDatarefVariable, globalDatarefIdName, writableOrReadable)
end

function do_often(doOftenExpression)
end

SCRIPT_DIRECTORY = "."

local luaUnit = require("luaunit")
local vhfHelper = require("vhf_helper")

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
	luaUnit.assertEquals(
		vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("124.5", 7),
		"7"
	)
	luaUnit.assertEquals(
		vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("124.57", 5),
		"5"
	)
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
	luaUnit.assertEquals(
		vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("136.9", 8),
		"_"
	)
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

local runner = luaUnit.LuaUnit.new()
runner:setOutputType("text", nil)
os.exit(runner:runSuite())
