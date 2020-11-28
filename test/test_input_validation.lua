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
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 2), "2")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("12", 4), "4")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("124", 5), "5")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("124.5", 7), "7")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("124.57", 5), "5")
end

function TestComFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 4), nil)
end

function TestComFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 3), "3")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("13", 6), "6")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("136", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("136.9", 8), nil)
end

TestNavFrequencyValidation = {}

function TestNavFrequencyValidation:setUp()
	self.validator = vhfHelperPackageExport.test.navFrequencyValidator
end

function TestNavFrequencyValidation:testValidFrequencyIsConsideredValid()
	luaUnit.assertEquals(self.validator:validate("117.000"), "117.000")
	luaUnit.assertEquals(self.validator:validate("108.550"), "108.550")
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
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("10", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("108", 2), "2")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("108.2", 5), "5")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("108.25", 0), "0")
end

function TestNavFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 2), nil)
end

function TestNavFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("11", 7), "7")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("117", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("117.9", 6), nil)
end

function TestNavFrequencyValidation:testInvalidFrequencyOutsideOf200ChannelsCanNotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("11", 3), "3")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("113", 4), "4")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("113.4", 6), nil)
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
	luaUnit.assertEquals(self.validator:validate("1190"), nil)
end

function TestTransponderCodeValidation:testAutocompletionWorks()
	luaUnit.assertEquals(self.validator:autocomplete("7"), "7000")
	luaUnit.assertEquals(self.validator:autocomplete("45"), "4500")
	luaUnit.assertEquals(self.validator:autocomplete("327"), "3270")
	luaUnit.assertEquals(self.validator:autocomplete("5612"), "5612")
end

TestBaroValidation = {}

function TestBaroValidation:setUp()
	self.validator = vhfHelperPackageExport.test.baroValidator
end

function TestBaroValidation:testValidBaroPressureIsConsideredValid()
	luaUnit.assertEquals(self.validator:validate("1013"), "1013")
	luaUnit.assertEquals(self.validator:validate("0920"), "0920")
	luaUnit.assertEquals(self.validator:validate("0921"), "0921")
end

function TestBaroValidation:testInvalidBaroPressureIsConsideredInvalid()
	luaUnit.assertEquals(self.validator:validate("1099"), nil)
	luaUnit.assertEquals(self.validator:validate("0810"), nil)
end

function TestBaroValidation:testAutocompletionWorks()
	luaUnit.assertEquals(self.validator:autocomplete("1"), "1000")
	luaUnit.assertEquals(self.validator:autocomplete("10"), "1000")
	luaUnit.assertEquals(self.validator:autocomplete("102"), "1020")
	luaUnit.assertEquals(self.validator:autocomplete("920"), "0920")

	luaUnit.assertEquals(self.validator:autocomplete("870"), "0870")
end

function TestBaroValidation:testShortValidPressureCanBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("9", 3), "3")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("93", 0), "0")
end

function TestBaroValidation:testLowShortValidPressureCanBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("8", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("89", 0), "0")
end

function TestBaroValidation:testLowFullValidPressureCanBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("0", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("08", 9), "9")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("089", 0), "0")
end

function TestBaroValidation:testTooLowFullValidPressureCannotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("0", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("08", 3), nil)
end

function TestBaroValidation:testObviouslyTooHighPressureCannotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 1), nil)
end

function TestBaroValidation:testTooHighPressureCannotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("10", 9), nil)
end

function TestBaroValidation:testSlightlyTooHighPressureCannotBeEntered()
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("", 1), "1")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("1", 0), "0")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("10", 8), "8")
	luaUnit.assertEquals(self.validator:getValidNumberCharacterOrNil("108", 5), nil)
end
