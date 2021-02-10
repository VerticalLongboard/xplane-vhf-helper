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
local flyWithLuaStub = require("xplane_fly_with_lua_stub")
local imguiStub = require("imgui_stub")
local LuaIniParserStub = require("LIP")
local LuaPlatform = require("lua_platform")
local Globals = require("vr-radio-helper.globals")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local vatsimbriefHelperStub = require("vatsimbrief_helper")

TestHighLevelBehaviour = {
	Constants = {
		comPanelButtonTitle = vhfHelperPackageExport.test.Panels.comFrequencyPanel.panelTitle,
		navPanelButtonTitle = vhfHelperPackageExport.test.Panels.navFrequencyPanel.panelTitle,
		radarPanelButtonTitle = vhfHelperPackageExport.test.Panels.radarPanel.panelTitle,
		transponderPanelButtonTitle = vhfHelperPackageExport.test.Panels.transponderCodePanel.panelTitle,
		baroPanelButtonTitle = vhfHelperPackageExport.test.Panels.baroPanel.panelTitle,
		SkrgPos = {6.1708, -75.4276}
	}
}

function TestHighLevelBehaviour:_pressButton(buttonTitle)
	imguiStub:pressButtonProgrammaticallyOnce(buttonTitle)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasButtonPressed())
end

function TestHighLevelBehaviour:_assertStringShowsUp(str)
	imguiStub:keepALookOutForString(str)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertTrue(imguiStub:wasWatchStringFound())
end

function TestHighLevelBehaviour:_enterNumberViaUserInterface(numberString)
	for i = 1, #numberString do
		self:_pressButton(numberString:sub(i, i))
	end
end

function TestHighLevelBehaviour:_switchToOtherFrequency(vhfNumber, linkedDatarefId, newFrequencyString)
	self:_enterNumberViaUserInterface(newFrequencyString)

	local d = flyWithLuaStub.datarefs[linkedDatarefId]

	luaUnit.assertNotEquals(d.data, tonumber(newFrequencyString))
	self:_pressButton("<" .. tostring(vhfNumber) .. ">")
	luaUnit.assertEquals(d.data, tonumber(newFrequencyString))
end

function TestHighLevelBehaviour:_switchToOtherTransponder(linkedDatarefId, newTransponderString)
	self:_enterNumberViaUserInterface(newTransponderString)

	local d = flyWithLuaStub.datarefs[linkedDatarefId]

	luaUnit.assertNotEquals(d.data, tonumber(newTransponderString))
	self:_pressButton("<X>")
	luaUnit.assertEquals(d.data, tonumber(newTransponderString))
end

function TestHighLevelBehaviour:_switchToOtherBaro(baroNumber, linkedDatarefId, newString)
	self:_enterNumberViaUserInterface(newString)

	local hg = Globals.convertHpaToHg(tonumber(newString))
	local d = flyWithLuaStub.datarefs[linkedDatarefId]

	luaUnit.assertNotEquals(d.data, hg)
	self:_pressButton("<" .. tostring(baroNumber) .. ">")
	luaUnit.assertEquals(d.data, hg)
end

function TestHighLevelBehaviour:_createInternalDatarefs()
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.currentLatitude,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialLatitude
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.currentLongitude,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialLongitude
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.currentAltitude,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialAltitude
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.currentTruePsi,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialTruePsi
	)

	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.firstComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialCom1Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.secondComFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialCom2Frequency
	)

	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.firstNavFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialNav1Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.secondNavFreq,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialNav2Frequency
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.transponderCode,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialTransponderCode
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.transponderMode,
		flyWithLuaStub.Constants.DatarefTypeInteger,
		TestDatarefs.Constants.initialTransponderMode
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.firstBaro,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialBaro1
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.secondBaro,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialBaro2
	)
	flyWithLuaStub:createSharedDatarefHandle(
		TestDatarefs.Constants.thirdBaro,
		flyWithLuaStub.Constants.DatarefTypeFloat,
		TestDatarefs.Constants.initialBaro3
	)
end

function TestHighLevelBehaviour:bootstrapVhfHelperWithConfiguration(iniConfigurationContent)
	luaUnit.assertNotNil(iniConfigurationContent)
	flyWithLuaStub:reset()
	vatsimbriefHelperStub:reset()
	self:_createInternalDatarefs()
	LuaIniParserStub.reset()
	LuaIniParserStub.setFileContentBeforeLoad(iniConfigurationContent)
	local vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:bootstrapAllMacros()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
end

function TestHighLevelBehaviour:setUp()
	self:bootstrapVhfHelperWithConfiguration({})
	flyWithLuaStub:activateMacro(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName, true)
end

function TestHighLevelBehaviour:testWindowShowsUpWhenConfigurationSaysSo()
	LuaIniParserStub.reset()
	flyWithLuaStub:reset()
	local iniContent = {}
	iniContent.Windows = {}
	iniContent.Windows.MainWindowInitiallyVisible = "yes"
	LuaIniParserStub.setFileContentBeforeLoad(iniContent)

	local dummyIniFilePath = SCRIPT_DIRECTORY .. "vhf_helper.ini"
	local iniFile = io.open(dummyIniFilePath, "w+b")
	iniFile:close()

	local vhfHelper = dofile("scripts/vhf_helper.lua")
	flyWithLuaStub:bootstrapAllMacros()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)
end

function TestHighLevelBehaviour:testPressingADisabledComNumberPanelButtonDoesNotDoAnything()
	self:_pressButton("2")
	self:_assertStringShowsUp("---.---")
end

function TestHighLevelBehaviour:testFixDefaultPlaneCompatibilityId()
	luaUnit.assertEquals(
		vhfHelperPackageExport.test.vhfHelperCompatibilityManager:getPlaneCompatibilityIdString(),
		"ICAO:....:TAILNUMBER:???:ACF_FILE_NAME:does_not_exist.acf:ACF_DESC:::ACF_MANUFACTURER:::ACF_STUDIO:::ACF_AUTHOR:::ACF_NAME::"
	)
end

function TestHighLevelBehaviour:testClosingThePanelChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "yes")
	LuaPlatform.Time.advanceNow(2.0)
	flyWithLuaStub:closeWindowByTitle(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName)
	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "no")
end

function TestHighLevelBehaviour:testDeactivatingTheScriptChangesPanelConfigurationAccordingly()
	luaUnit.assertIsTrue(
		flyWithLuaStub:isMacroActive(vhfHelperPackageExport.test.vhfHelperLoop.Constants.defaultMacroName)
	)

	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "yes")
	flyWithLuaStub:activateAllMacros(false)
	luaUnit.assertEquals(vhfHelperPackageExport.test.Config.Content.Windows.MainWindowInitiallyVisible, "no")
end

function TestHighLevelBehaviour:testCurrentComFrequenciesAreShownSomewhere()
	local freqAsString = tostring(TestDatarefs.Constants.initialCom1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)

	freqAsString = tostring(TestDatarefs.Constants.initialCom2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)
end

function TestHighLevelBehaviour:testEnteredComStringIsShownSomewhere()
	local freqString = "132805"
	self:_enterNumberViaUserInterface(freqString)
	self:_assertStringShowsUp(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
end

function TestHighLevelBehaviour:testSwitchingComDoesSwitch()
	local freqString = "129725"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondComFreq, freqString)

	local freqString2 = "122650"
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondComFreq, freqString2)
end

function TestHighLevelBehaviour:testCurrentNavFrequenciesAreShownSomewhere()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	local freqAsString = tostring(TestDatarefs.Constants.initialNav1Frequency)
	local fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)

	freqAsString = tostring(TestDatarefs.Constants.initialNav2Frequency)
	fullFrequencyString = freqAsString:sub(1, 3) .. "." .. freqAsString:sub(4, 6)
	self:_assertStringShowsUp(fullFrequencyString)
end

function TestHighLevelBehaviour:testEnteredNavStringIsShownSomewhere()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	local freqString = "111800"
	self:_enterNumberViaUserInterface(freqString)
	self:_assertStringShowsUp(freqString:sub(1, 3) .. "." .. freqString:sub(4, 6))
end

function TestHighLevelBehaviour:testSwitchingNavDoesSwitch()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondNavFreq, "10965")
	self:_switchToOtherFrequency(2, TestDatarefs.Constants.secondNavFreq, "11535")
end

function TestHighLevelBehaviour:testSwitchingTransponderDoesSwitch()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	self:_switchToOtherTransponder(TestDatarefs.Constants.transponderCode, "4066")
	self:_switchToOtherTransponder(TestDatarefs.Constants.transponderCode, "1000")
end

function TestHighLevelBehaviour:testInvalidTransponderCodeIsDisplayedCorrectly()
	flyWithLuaStub.datarefs[TestDatarefs.Constants.transponderCode].data = 9999
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	self:_assertStringShowsUp("----")
end

function TestHighLevelBehaviour:testCurrentTransponderCodeIsShownSomewhere()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	local codeString = tostring(TestDatarefs.Constants.initialTransponderCode)
	self:_assertStringShowsUp(codeString)
end

function TestHighLevelBehaviour:testSwitchingBaroDoesSwitch()
	self:_pressButton(self.Constants.baroPanelButtonTitle)
	self:_switchToOtherBaro(2, TestDatarefs.Constants.secondBaro, "920")
	self:_switchToOtherBaro(2, TestDatarefs.Constants.secondBaro, "1023")
	self:_switchToOtherBaro(2, TestDatarefs.Constants.secondBaro, "1082")
	self:_switchToOtherBaro(3, TestDatarefs.Constants.thirdBaro, "1082")
end

function TestHighLevelBehaviour:testCurrentBarosAreShownSomewhere()
	self:_pressButton(self.Constants.baroPanelButtonTitle)

	self:_assertStringShowsUp(
		tostring(Utilities.roundFloatingPointToNearestInteger(Globals.convertHgToHpa(TestDatarefs.Constants.initialBaro1)))
	)
	self:_assertStringShowsUp(
		"0" ..
			tostring(Utilities.roundFloatingPointToNearestInteger(Globals.convertHgToHpa(TestDatarefs.Constants.initialBaro2)))
	)
	self:_assertStringShowsUp(
		tostring(Utilities.roundFloatingPointToNearestInteger(Globals.convertHgToHpa(TestDatarefs.Constants.initialBaro3)))
	)
end

function TestHighLevelBehaviour:testTogglePanelCommandTogglesPanel()
	local toggleWindowCommandName = "FlyWithLua/VR_Radio_Helper/TogglePanel"
	local windowTitle = vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.defaultWindowName

	luaUnit.assertIsTrue(flyWithLuaStub:isWindowOpen(flyWithLuaStub:getWindowByTitle(windowTitle)))
	flyWithLuaStub:executeCommand(toggleWindowCommandName)
	flyWithLuaStub:cleanupBeforeRunningNextFrame()
	luaUnit.assertNil(flyWithLuaStub:getWindowByTitle(windowTitle))
	flyWithLuaStub:executeCommand(toggleWindowCommandName)
	flyWithLuaStub:cleanupBeforeRunningNextFrame()
	luaUnit.assertIsTrue(flyWithLuaStub:isWindowOpen(flyWithLuaStub:getWindowByTitle(windowTitle)))
end

function TestHighLevelBehaviour:testTransmoderModeIsSwitched()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	local tm = flyWithLuaStub.datarefs[TestDatarefs.Constants.transponderMode]
	luaUnit.assertEquals(tm.data, TestDatarefs.Constants.initialTransponderMode)

	local newMode = 0
	self:_pressButton(vhfHelperPackageExport.test.transponderModeToDescriptor[newMode + 1])
	luaUnit.assertEquals(tm.data, newMode)

	local newMode2 = 3
	self:_pressButton(vhfHelperPackageExport.test.transponderModeToDescriptor[newMode2 + 1])
	luaUnit.assertEquals(tm.data, newMode2)
end

function TestHighLevelBehaviour:_runForSomeTime(timeSec)
	local startTime = LuaPlatform.Time.now()
	local stepSize = 1.0 / 60.0
	while (LuaPlatform.Time.now() - startTime < timeSec) do
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		LuaPlatform.Time.advanceNow(stepSize)
	end
end

function TestHighLevelBehaviour:testRadarPanelOpensCorrectly()
	self:_pressButton(self.Constants.radarPanelButtonTitle)
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
end

function TestHighLevelBehaviour:testRadarPanelShowsAtLeastOnePlane()
	self:_pressButton(self.Constants.radarPanelButtonTitle)
	vatsimbriefHelperStub:emitVatsimDataRefreshEvent()
	self:_runForSomeTime(0.5)
	-- self:_assertStringShowsUp("DLH57D")
end

function TestHighLevelBehaviour:_runNFramesAndGetFps(totalFrames)
	local framesRendered = 0
	local totalTime = 0.0
	local simulatedFrameTime = 1.0 / 60.0
	local totalSimulatedTime = 0.0
	for f = 1, totalFrames do
		totalSimulatedTime = totalSimulatedTime + simulatedFrameTime
		local beforeTime = os.clock()
		flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
		local afterTime = os.clock()
		local tDiff = afterTime - beforeTime
		framesRendered = framesRendered + 1
		totalTime = totalTime + tDiff
		LuaPlatform.Time.advanceNow(simulatedFrameTime)
	end

	local frameTime = totalTime / framesRendered
	local fps = framesRendered / totalTime

	logMsg(
		("totalTime=%f simulated=%f frames=%d frameTime=%f FPS=%f"):format(
			totalTime,
			totalSimulatedTime,
			framesRendered,
			frameTime,
			fps
		)
	)
	return fps
end

function TestHighLevelBehaviour:testCOMPanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_runForSomeTime(3.0)
	local fps = self:_runNFramesAndGetFps(100)
	luaUnit.assertTrue(fps > 1000.0)
end

function TestHighLevelBehaviour:testCOMAndSidePanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_openSidePanel()
	self:_runForSomeTime(3.0)
	local fps = self:_runNFramesAndGetFps(100)
	luaUnit.assertTrue(fps > 1000.0)
end

function TestHighLevelBehaviour:testNAVPanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_pressButton(self.Constants.navPanelButtonTitle)
	self:_runForSomeTime(3.0)
	local fps = self:_runNFramesAndGetFps(100)
	luaUnit.assertTrue(fps > 1000.0)
end

function TestHighLevelBehaviour:testTPPanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_pressButton(self.Constants.transponderPanelButtonTitle)
	self:_runForSomeTime(3.0)
	local fps = self:_runNFramesAndGetFps(100)
	luaUnit.assertTrue(fps > 1000.0)
end

function TestHighLevelBehaviour:testBaroPanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_pressButton(self.Constants.baroPanelButtonTitle)
	self:_runForSomeTime(3.0)
	local fps = self:_runNFramesAndGetFps(100)
	luaUnit.assertTrue(fps > 1000.0)
end

local allVatsimClientsWhenEuropeIsCrowded = require("allVatsimClientsWhenEuropeIsCrowded")

function TestHighLevelBehaviour:testRadarPanelRunsFastEnoughWithoutCallingImguiMethods()
	self:_pressButton(self.Constants.radarPanelButtonTitle)
	vatsimbriefHelperStub:overrideTestVatsimClients(allVatsimClientsWhenEuropeIsCrowded)
	local latDataref = flyWithLuaStub.datarefs[TestDatarefs.Constants.currentLatitude]
	local lonDataref = flyWithLuaStub.datarefs[TestDatarefs.Constants.currentLongitude]
	local eddmPos = {48.3537, 11.7751}

	latDataref.data = eddmPos[1]
	lonDataref.data = eddmPos[2]

	flyWithLuaStub:writeAllDatarefValuesToLocalVariables()
	vatsimbriefHelperStub:emitVatsimDataRefreshEvent()
	self:_runForSomeTime(1.0)

	local fps = self:_runNFramesAndGetFps(10)
	-- luaUnit.assertTrue(fps > 120.0)
end

function TestHighLevelBehaviour:testSideWindowOpensAndRendersCorrectly()
	self:_openSidePanel()

	TRACK_ISSUE("Imgui", "creating a window while rendering", "Wait one frame")
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()

	luaUnit.assertIsTrue(
		flyWithLuaStub:isWindowOpen(
			flyWithLuaStub:getWindowByTitle(vhfHelperPackageExport.test.vhfHelperSideWindow.Constants.defaultWindowName)
		)
	)
end

function TestHighLevelBehaviour:_openSidePanel()
	if (vhfHelperPackageExport.test.vhfHelperSideWindow:isVisible()) then
		self:_pressButton(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.SidePanelVisibleButtonTitle)
	else
		self:_pressButton(vhfHelperPackageExport.test.vhfHelperMainWindow.Constants.SidePanelHiddenButtonTitle)
	end
end

function TestHighLevelBehaviour:testSideWindowMulticrewSupportShowsUpInDefaultState()
	self:_openSidePanel()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertStringShowsUp(
		vhfHelperPackageExport.test.vhfHelperSideWindow.Constants.MulticrewStateToMessage[
			vhfHelperPackageExport.test.vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
		][1]
	)
end

function TestHighLevelBehaviour:testComPanelShowsAtcStationInfoWhenVatsimbriefHelperIsAvailable()
	vatsimbriefHelperStub:activateInterface()
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	vatsimbriefHelperStub:emitVatsimDataRefreshEvent()
	flyWithLuaStub.datarefs[TestDatarefs.Constants.firstComFreq].data = 129200
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertStringShowsUp("129.200")
	self:_assertStringShowsUp("TPA_GND")
	self:_assertStringShowsUp("Just testing")
	self:_assertStringShowsUp("COM2: UNKNOWN")

	flyWithLuaStub.datarefs[TestDatarefs.Constants.firstComFreq].data = 122800
	flyWithLuaStub:runNextCompleteFrameAfterExternalWritesToDatarefs()
	self:_assertStringShowsUp("Unicom")
end
