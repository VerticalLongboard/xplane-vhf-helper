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
Globals = require("vr-radio-helper.globals")

TestDatarefs = {
	Constants = {
		firstComFreq = "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
		secondComFreq = "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
		firstNavFreq = "sim/cockpit2/radios/actuators/nav1_frequency_hz",
		secondNavFreq = "sim/cockpit2/radios/actuators/nav2_frequency_hz",
		transponderCode = "sim/cockpit2/radios/actuators/transponder_code",
		transponderMode = "sim/cockpit2/radios/actuators/transponder_mode",
		firstComInterchangeFreq = "VHFHelper/InterchangeCOM1Frequency",
		secondComInterchangeFreq = "VHFHelper/InterchangeCOM2Frequency",
		firstNavInterchangeFreq = "VHFHelper/InterchangeNAV1Frequency",
		secondNavInterchangeFreq = "VHFHelper/InterchangeNAV2Frequency",
		transponderCodeInterchangeFreq = "VHFHelper/InterchangeTransponderCode",
		firstBaro = "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",
		secondBaro = "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot",
		thirdBaro = "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby",
		currentLatitude = "sim/flightmodel/position/latitude",
		currentLongitude = "sim/flightmodel/position/longitude",
		currentAltitude = "sim/flightmodel/position/elevation",
		currentTruePsi = "sim/flightmodel/position/true_psi",
		initialLatitude = TestHighLevelBehaviour.Constants.SkrgPos[1],
		initialLongitude = TestHighLevelBehaviour.Constants.SkrgPos[2],
		initialAltitude = 1000.0,
		initialTruePsi = 270.0,
		initialCom1Frequency = 131200,
		initialCom2Frequency = 119500,
		initialNav1Frequency = 11700,
		initialNav2Frequency = 11660,
		initialTransponderCode = 1000,
		initialTransponderMode = 1,
		initialBaro1 = Globals.convertHpaToHg(1032),
		initialBaro2 = Globals.convertHpaToHg(910),
		initialBaro3 = 29.92
	}
}

function TestDatarefs:setUp()
	TestHighLevelBehaviour:bootstrapVhfHelperWithConfiguration({})
end

function TestDatarefs:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(d1, d2, expectedAccessType)
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

function TestDatarefs:testTwoIndependentComInterchangeFrequenciesAreDefinedCorrectly()
	local f1 = flyWithLuaStub.datarefs[self.Constants.firstComInterchangeFreq]
	local f2 = flyWithLuaStub.datarefs[self.Constants.secondComInterchangeFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(f1, f2, flyWithLuaStub.Constants.AccessTypeWritable)
end

function TestDatarefs:testTwoIndependentComLinkedFrequenciesAreDefinedCorrectly()
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(c1, c2, flyWithLuaStub.Constants.AccessTypeReadable)
end

function TestDatarefs:testTwoIndependentNavInterchangeFrequenciesAreDefinedCorrectly()
	local f1 = flyWithLuaStub.datarefs[self.Constants.firstNavInterchangeFreq]
	local f2 = flyWithLuaStub.datarefs[self.Constants.secondNavInterchangeFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(f1, f2, flyWithLuaStub.Constants.AccessTypeWritable)
end

function TestDatarefs:testTwoIndependentNavLinkedFrequenciesAreDefinedCorrectly()
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstNavFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondNavFreq]

	self:_assertDifferentLocalVariablesDeclaredForTwoDatarefs(c1, c2, flyWithLuaStub.Constants.AccessTypeReadable)
end

function TestDatarefs:testExternalComChangeViaInterchangeIgnoresInvalidFrequencies()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstComInterchangeFreq]
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

function TestDatarefs:testExternalComChangeViaInterchangeSpeaksNumber()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstComInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.firstComFreq]

	luaUnit.assertEquals(c1.data, i1.data)
	oldFrequency = c1.data
	local newFrequency = 123800
	luaUnit.assertNotEquals(oldFrequency, newFrequency)

	i1.data = newFrequency
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(flyWithLuaStub:getLastSpeakString(), "won too tree decimal ate ")
end

function TestDatarefs:testExternalTransponderCodeChangeViaInterchangeSpeaksNumber()
	local i1 = flyWithLuaStub.datarefs[self.Constants.transponderCodeInterchangeFreq]
	local c1 = flyWithLuaStub.datarefs[self.Constants.transponderCode]

	luaUnit.assertEquals(c1.data, i1.data)
	oldCode = c1.data
	local newCode = 6430
	luaUnit.assertNotEquals(oldCode, newCode)

	i1.data = newCode
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertEquals(flyWithLuaStub:getLastSpeakString(), "siccs fore tree zeero ")
end

function TestDatarefs:testExternalComChangeViaInterchangeUpdatesLocalComFrequencies()
	local i1 = flyWithLuaStub.datarefs[self.Constants.firstComInterchangeFreq]
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

function TestDatarefs:testInternalComChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondComInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225

	vhfHelperPackageExport.test.comLinkedDatarefs[2]:emitNewValue(newFrequency)
	flyWithLuaStub:readbackAllWritableDatarefs()

	for f = 1, 10 do
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end

function TestDatarefs:testExternalComChangeLeadsToStableFrequencyAcrossMultipleFrames()
	local i2 = flyWithLuaStub.datarefs[self.Constants.secondComInterchangeFreq]
	local c2 = flyWithLuaStub.datarefs[self.Constants.secondComFreq]

	local newFrequency = 129225
	i2.data = newFrequency

	for f = 1, 10 do
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		luaUnit.assertEquals(i2.data, newFrequency)
		luaUnit.assertEquals(c2.data, newFrequency)
	end
end
