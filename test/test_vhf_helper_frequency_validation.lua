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
	local f = vhfHelperPackageExport.test.autocompleteFrequencyString
	local e = luaUnit.assertEquals
	e(f("123."), "123.")
	e(f("123"), "123")
	e(f("12"), "12")
	e(f("1"), "1")
	e(f(""), "")
end

function TestVhfHelperFrequencyValidation:testValidFrequencyCanBeEntered()
	local f = vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband
	local e = luaUnit.assertEquals
	e(f("", 1), "1")
	e(f("1", 2), "2")
	e(f("12", 4), "4")
	e(f("124", 5), "5")
	e(f("124.5", 7), "7")
	e(f("124.57", 5), "5")
end

function TestVhfHelperFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("", 1), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband("1", 4), "_")
end

function TestVhfHelperFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	local f = vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband
	local e = luaUnit.assertEquals
	e(f("", 1), "1")
	e(f("1", 3), "3")
	e(f("13", 6), "6")
	e(f("136", 9), "9")
	e(f("136.9", 8), "_")
end
