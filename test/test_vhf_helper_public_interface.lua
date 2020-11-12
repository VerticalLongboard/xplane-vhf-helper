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
TestVhfHelperPublicInterface = {
	Constants = {
		initialCom1Frequency = 131200,
		initialCom2Frequency = 119500
	}
}

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

function TestVhfHelperPublicInterface:testValidationWorks()
	local someValidFreq = "124.225"
	luaUnit.assertIsTrue(self.activeInterface.isValidFrequency(someValidFreq))

	local someInvalidFreq = "199.228"
	luaUnit.assertIsFalse(self.activeInterface.isValidFrequency(someInvalidFreq))
end

function TestVhfHelperPublicInterface:testTuningInAFrequencyIsReportedAsTunedIn()
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
	flyWithLuaStub:bootstrapAllMacros()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertIsTrue(self.activeInterface.isCurrentlyTunedIn("119.500"))
end
