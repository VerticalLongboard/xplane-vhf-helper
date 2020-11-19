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
local imguiStub = require("imgui_stub")
local eventBusStub = require("vhf_helper_modules.eventbus")

-- PublicInterface = require("vhf_helper.public_interface")

TestPublicInterface = {}

function TestPublicInterface:setUp()
	vhfHelperPackageExport.test.activatePublicInterface()
	self.activeInterface = VHFHelperPublicInterface
	luaUnit.assertNotNil(self.activeInterface)
end

function TestPublicInterface:tearDown()
	vhfHelperPackageExport.test.deactivatePublicInterface()
	self.activeInterface = VHFHelperPublicInterface
	luaUnit.assertNil(self.activeInterface)
end

function TestPublicInterface:testFixInterface()
	luaUnit.assertEquals(self.activeInterface.getInterfaceVersion(), 1)
	luaUnit.assertNotNil(self.activeInterface.enterFrequencyProgrammaticallyAsString)
	luaUnit.assertNotNil(self.activeInterface.isCurrentlyTunedIn)
	luaUnit.assertNotNil(self.activeInterface.isCurrentlyEntered)
	luaUnit.assertNotNil(self.activeInterface.isValidFrequency)
end

function TestPublicInterface:testEnteringProgrammaticallyReportsEnteredCurrently()
	local enterFreq = "132.850"
	luaUnit.assertEquals(self.activeInterface.enterFrequencyProgrammaticallyAsString(enterFreq), enterFreq)
	luaUnit.assertIsTrue(self.activeInterface.isCurrentlyEntered(enterFreq))
end

function TestPublicInterface:testValidationWorks()
	local someValidFreq = "124.225"
	luaUnit.assertIsTrue(self.activeInterface.isValidFrequency(someValidFreq))

	local someInvalidFreq = "199.228"
	luaUnit.assertIsFalse(self.activeInterface.isValidFrequency(someInvalidFreq))
end

TestPublicInterfaceAndEvents = {}

function TestPublicInterfaceAndEvents:setUp()
	VHFHelperEventBus.eventsEmittedSoFar = {}
	TestHighLevelBehaviour:createInternalDatarefsAndBootstrap()
	flyWithLuaStub:activateMacro(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName, true)
end

function TestPublicInterfaceAndEvents:testTuningInAFrequencyIsReportedAsTunedIn()
	luaUnit.assertIsTrue(VHFHelperPublicInterface.isCurrentlyTunedIn("131.200"))
end

function TestPublicInterfaceAndEvents:testOpeningMainWindowActivatesPublicInterface()
	luaUnit.assertNotNil(VHFHelperPublicInterface)
	flyWithLuaStub:closeWindowByTitle(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName)
	luaUnit.assertNil(VHFHelperPublicInterface)
end

function TestPublicInterfaceAndEvents:_assertNumOfEventsWithTypeWereEmitted(event, expectedNumber)
	local numEmitted = 0
	for _, e in pairs(VHFHelperEventBus.eventsEmittedSoFar) do
		if (e == event) then
			numEmitted = numEmitted + 1
		end
	end

	luaUnit.assertEquals(numEmitted, expectedNumber)
end

function TestPublicInterfaceAndEvents:testChangeEventIsEmittedWhenEnteringAndChangingNextCOMFrequency()
	VHFHelperEventBus.eventsEmittedSoFar = {}
	local freqString = "122810"

	TestHighLevelBehaviour:_enterNumberViaUserInterface(freqString)
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, 6)

	TestHighLevelBehaviour:_pressButton("<1>")
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, 7)
end

function TestPublicInterfaceAndEvents:testChangingToAnAlreadySetFrequencyStillEmitsAnEvent()
	local freqString = "122810"

	TestHighLevelBehaviour:_enterNumberViaUserInterface(freqString)
	TestHighLevelBehaviour:_pressButton("<2>")
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	TestHighLevelBehaviour:_enterNumberViaUserInterface(freqString)
	VHFHelperEventBus.eventsEmittedSoFar = {}
	TestHighLevelBehaviour:_pressButton("<2>")
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, 1)
end

function TestPublicInterfaceAndEvents:testChangeEventIsEmittedWhenBackspacingOrClearingNextCOMFrequency()
	local backspaceButton = "Del"
	local clearButton = "Clr"
	local freqString = "122"
	TestHighLevelBehaviour:_enterNumberViaUserInterface(freqString)
	VHFHelperEventBus.eventsEmittedSoFar = {}

	TestHighLevelBehaviour:_pressButton(backspaceButton)
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, 1)

	TestHighLevelBehaviour:_pressButton(clearButton)
	local sameWhenBackspacingAnEmptyString = 2
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, sameWhenBackspacingAnEmptyString)

	TestHighLevelBehaviour:_pressButton(backspaceButton)
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, sameWhenBackspacingAnEmptyString)

	TestHighLevelBehaviour:_pressButton(clearButton)
	self:_assertNumOfEventsWithTypeWereEmitted(VHFHelperEventOnFrequencyChanged, sameWhenBackspacingAnEmptyString)
end

function TestPublicInterfaceAndEvents:testProgrammaticallyEnteredFrequencyShowsUpAndIsReported()
	local freqString = "127.775"
	luaUnit.assertIsFalse(VHFHelperPublicInterface.isCurrentlyEntered(freqString))
	VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString(freqString)
	TestHighLevelBehaviour:_assertStringShowsUp(freqString)
	luaUnit.assertTrue(VHFHelperPublicInterface.isCurrentlyEntered(freqString))
end
