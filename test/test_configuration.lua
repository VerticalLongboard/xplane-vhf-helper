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
TestVhfHelperConfiguration = {}

require("vhf_helper.components.configuration")

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
