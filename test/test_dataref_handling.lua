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
TestDatarefHandling = {
	Constants = {
		firstComFreq = "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
		secondComFreq = "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
		firstInterchangeFreq = "VHFHelper/InterchangeCOM1Frequency",
		secondInterchangeFreq = "VHFHelper/InterchangeCOM2Frequency",
		firstNavFreq = "sim/cockpit2/radios/actuators/nav1_frequency_hz",
		secondNavFreq = "sim/cockpit2/radios/actuators/nav2_frequency_hz",
		firstNavInterchangeFreq = "VHFHelper/InterchangeNAV1Frequency",
		secondNavInterchangeFreq = "VHFHelper/InterchangeNAV2Frequency",
		initialComFrequency = 118000,
		initialCom1Frequency = 131200,
		initialCom2Frequency = 119500,
		initialNav1Frequency = 117000,
		initialNav2Frequency = 116600
	}
}

function TestDatarefHandling:setUp()
	TestHighLevelBehaviour:createInternalDatarefsAndBootstrap()
end

function TestDatarefHandling:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(d1, d2, expectedAccessType)
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

	luaUnit.assertEquals(variableCount, 2)
end

function TestDatarefHandling:testTwoIndependentComInterchangeFrequenciesAreDefinedCorrectly()
	local f1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local f2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(f1, f2, flyWithLuaStub.Constants.AccessTypeWritable)
end

function TestDatarefHandling:testTwoIndependentComLinkedFrequenciesAreDefinedCorrectly()
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(c1, c2, flyWithLuaStub.Constants.AccessTypeReadable)
end

function TestDatarefHandling:testExternalChangeViaInterchangeIgnoresInvalidFrequencies()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]

	luaUnit.assertEquals(c1.data, i1.data)
	oldFrequency = c1.data
	local newFrequency = -12999994
	luaUnit.assertNotEquals(oldFrequency, newFrequency)

	i1.data = newFrequency
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(i1.data, oldFrequency)
	luaUnit.assertEquals(c1.data, oldFrequency)
end

function TestDatarefHandling:testExternalChangeViaInterchangeUpdatesLocalComFrequencies()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]

	luaUnit.assertEquals(c1.data, i1.data)
	oldFrequency = c1.data
	local newFrequency = 123800
	luaUnit.assertNotEquals(oldFrequency, newFrequency)

	i1.data = newFrequency
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(i1.data, newFrequency)
	luaUnit.assertEquals(c1.data, newFrequency)
end

function TestDatarefHandling:testInternalChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225

	vhfHelperPackageExport.test.COMLinkedDatarefs[2]:emitNewValue(newFrequency)
	flyWithLuaStub:readbackAllWritableDatarefs()

	for f = 1, 10 do
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end

function TestDatarefHandling:testExternalChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225
	i2.data = newFrequency

	for f = 1, 10 do
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end
