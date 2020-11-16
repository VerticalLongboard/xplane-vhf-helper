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
TestComFrequencyValidation = {}

function TestComFrequencyValidation:setUp()
	self.validator = vhfHelperPackageExport.test.comFrequencyValidator
end

function TestComFrequencyValidation:testAlmostValidFrequencyIsConsideredValid()
	luaUnit.assertEquals(self.validator:validate("123.420"), "123.425")
end

function TestComFrequencyValidation:testObviouslyInvalidFrequencyIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("923x420"), nil)
end

function TestComFrequencyValidation:testSomeRandomStringIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("__1l]"), nil)
end

function TestComFrequencyValidation:testNilOrEmptyStringIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate(nil), nil)
	luaUnit.assertEquals(self.validator:validate(""), nil)
end

function TestComFrequencyValidation:testFullFrequencyIsNotChangedByAutocompletion()
	luaUnit.assertEquals(self.validator:autocomplete("123.500"), "123.500")
end

function TestComFrequencyValidation:testFiveDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("123.42"), "123.425")
	luaUnit.assertEquals(self.validator:autocomplete("123.43"), "123.430")
end

function TestComFrequencyValidation:testFourDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("123.4"), "123.400")
end

function TestComFrequencyValidation:testLessThanFourDigitFrequencyIsNotAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("123."), "123.")
	luaUnit.assertEquals(self.validator:autocomplete("123"), "123")
	luaUnit.assertEquals(self.validator:autocomplete("12"), "12")
	luaUnit.assertEquals(self.validator:autocomplete("1"), "1")
	luaUnit.assertEquals(self.validator:autocomplete(""), "")
end

function TestComFrequencyValidation:testValidFrequencyCanBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 2), "2")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("12", 4), "4")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("124", 5), "5")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("124.5", 7), "7")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("124.57", 5), "5")
end

function TestComFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 4), "_")
end

function TestComFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 3), "3")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("13", 6), "6")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("136", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("136.9", 8), "_")
end

TestNavFrequencyValidation = {}

function TestNavFrequencyValidation:setUp()
	self.validator = vhfHelperPackageExport.test.navFrequencyValidator
end

function TestNavFrequencyValidation:testSlightlyInvalidFrequencyIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("113.455"), nil)
end

function TestNavFrequencyValidation:testObviouslyInvalidFrequencyIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("223x420"), nil)
end

function TestNavFrequencyValidation:testSomeRandomStringIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("_s_1l]"), nil)
end

function TestNavFrequencyValidation:testNilOrEmptyStringIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate(nil), nil)
	luaUnit.assertEquals(self.validator:validate(""), nil)
end

function TestNavFrequencyValidation:testFullFrequencyIsNotChangedByAutocompletion()
	luaUnit.assertEquals(self.validator:autocomplete("112.200"), "112.200")
end

function TestNavFrequencyValidation:testFiveDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("113.42"), "113.420")
	luaUnit.assertEquals(self.validator:autocomplete("113.40"), "113.400")
end

function TestNavFrequencyValidation:testFourDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("109.4"), "109.400")
end

function TestNavFrequencyValidation:testLessThanFourDigitFrequencyIsNotAutocompleted()
	luaUnit.assertEquals(self.validator:autocomplete("110."), "110.")
	luaUnit.assertEquals(self.validator:autocomplete("110"), "110")
	luaUnit.assertEquals(self.validator:autocomplete("11"), "11")
	luaUnit.assertEquals(self.validator:autocomplete("1"), "1")
	luaUnit.assertEquals(self.validator:autocomplete(""), "")
end

function TestNavFrequencyValidation:testValidFrequencyCanBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("10", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("108", 2), "2")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("108.2", 5), "5")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("108.25", 0), "0")
end

function TestNavFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 2), "_")
end

function TestNavFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("11", 7), "7")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("117", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("117.9", 6), "_")
end

function TestNavFrequencyValidation:testInvalidFrequencyOutsideOf200ChannelsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("1", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("11", 3), "3")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("113", 4), "4")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrUnderscore("113.4", 6), "_")
end

TestTransponderCodeValidation = {}

function TestTransponderCodeValidation:setUp()
	self.validator = vhfHelperPackageExport.test.transponderCodeValidator
end

function TestTransponderCodeValidation:testValidTransponderCodeIsConsideredValid()
	luaUnit.assertEquals(self.validator:validate("6456"), "6456")
	luaUnit.assertEquals(self.validator:validate("1000"), "1000")
	luaUnit.assertEquals(self.validator:validate("0000"), "0000")
end

function TestTransponderCodeValidation:testInvalidTransponderCodeIsNotConsideredValid()
	luaUnit.assertEquals(self.validator:validate("7856"), nil)
	luaUnit.assertEquals(self.validator:validate("7778"), nil)
end

function TestTransponderCodeValidation:testAutocompletionWorks()
	luaUnit.assertEquals(self.validator:autocomplete("7"), "7000")
	luaUnit.assertEquals(self.validator:autocomplete("45"), "4500")
	luaUnit.assertEquals(self.validator:autocomplete("327"), "3270")
	luaUnit.assertEquals(self.validator:autocomplete("5612"), "5612")
end
