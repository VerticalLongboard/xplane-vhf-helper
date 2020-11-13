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
TestFrequencyValidation = {}

function TestFrequencyValidation:testAlmostValidFrequencyIsConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:validate("123.420"), "123.425")
end

function TestFrequencyValidation:testObviouslyInvalidFrequencyIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:validate("923x420"), nil)
end

function TestFrequencyValidation:testSomeRandomStringIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:validate("__1l]"), nil)
end

function TestFrequencyValidation:testNilOrEmptyStringIsNotConsideredValid()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:validate(nil), nil)
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:validate(""), nil)
end

function TestFrequencyValidation:testFullFrequencyIsNotChangedByAutocompletion()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123.500"), "123.500")
end

function TestFrequencyValidation:testFiveDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123.42"), "123.425")
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123.43"), "123.430")
end

function TestFrequencyValidation:testFourDigitFrequencyIsAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123.4"), "123.400")
end

function TestFrequencyValidation:testLessThanFourDigitFrequencyIsNotAutocompleted()
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123."), "123.")
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("123"), "123")
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("12"), "12")
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete("1"), "1")
	luaUnit.assertEquals(vhfHelperPackageExport.test.comFrequencyValidator:autocomplete(""), "")
end

function TestFrequencyValidation:testValidFrequencyCanBeEntered()
	local validator = vhfHelperPackageExport.test.comFrequencyValidator
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("1", 2), "2")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("12", 4), "4")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("124", 5), "5")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("124.5", 7), "7")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("124.57", 5), "5")
end

function TestFrequencyValidation:testInvalidFrequencyFirstDigitsCanNotBeEntered()
	local validator = vhfHelperPackageExport.test.comFrequencyValidator
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("1", 4), "_")
end

function TestFrequencyValidation:testInvalidFrequencyLastDigitsCanNotBeEntered()
	local validator = vhfHelperPackageExport.test.comFrequencyValidator
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("", 1), "1")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("1", 3), "3")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("13", 6), "6")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("136", 9), "9")
	luaUnit.assertEquals(validator:getValidNumberCharacterOrUnderscore("136.9", 8), "_")
end
