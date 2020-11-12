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
local emptyString = ""
local decimalCharacter = "."
local underscoreCharacter = "_"

local function printLogMessage(messageString)
	logMsg(("VHF Helper: %s"):format(messageString or "NIL"))
end

local licensesOfDependencies = {
	{"Lua INI Parser", "MIT License", "https://github.com/Dynodzzo/Lua_INI_Parser"},
	{"Lua Event Bus", "MIT License", "https://github.com/prabirshrestha/lua-eventbus"},
	{"LuaUnit", "BSD License", "https://github.com/bluebird75/luaunit"},
	{"FlyWithLua", "MIT License", "https://github.com/X-Friese/FlyWithLua"}
}

for i = 1, #licensesOfDependencies do
	printLogMessage(
		("VHF Helper using '%s' with license '%s'. Project homepage: %s"):format(
			licensesOfDependencies[i][1],
			licensesOfDependencies[i][2],
			licensesOfDependencies[i][3]
		)
	)
end

local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end
local function replaceCharacter(str, pos, newCharacter)
	return str:sub(1, pos - 1) .. newCharacter .. str:sub(pos + 1)
end

local nextVhfFrequency = emptyString

local function validateFullFrequencyString(fullFrequencyString)
	if (fullFrequencyString == nil) then
		return nil
	end
	if (fullFrequencyString:len() ~= 7) then
		return nil
	end
	if (fullFrequencyString:sub(4, 4) ~= decimalCharacter) then
		return nil
	end

	cleanFrequencyString = fullFrequencyString:sub(1, 3) .. fullFrequencyString:sub(5, 7)

	frequencyNumber = tonumber(cleanFrequencyString)
	minVhfFrequency = 118000
	maxVhfFrequency = 136975
	if (frequencyNumber < minVhfFrequency or frequencyNumber > maxVhfFrequency) then
		return nil
	end

	minorOneDigit = cleanFrequencyString:sub(6, 6)
	minorTenDigit = cleanFrequencyString:sub(5, 5)
	if (minorOneDigit ~= "0" and minorOneDigit ~= "5") then
		minorOneDigit = "0"
		cleanFrequencyString = replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
	end

	if (minorTenDigit == "2" or minorTenDigit == "7") then
		minorOneDigit = "5"
		cleanFrequencyString = replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
	end

	return cleanFrequencyString:sub(1, 3) .. decimalCharacter .. cleanFrequencyString:sub(4, 7)
end

local function autocompleteFrequencyString(fullFrequencyString)
	nextStringLength = fullFrequencyString:len()
	if (nextStringLength == 5) then
		fullFrequencyString = fullFrequencyString .. "00"
	elseif (nextStringLength == 6) then
		minorTenDigit = fullFrequencyString:sub(6, 6)
		if (minorTenDigit == "2" or minorTenDigit == "7") then
			fullFrequencyString = fullFrequencyString .. "5"
		else
			fullFrequencyString = fullFrequencyString .. "0"
		end
	end

	return fullFrequencyString
end

VHFHelperPublicInterface = nil
local EventBus = require("eventbus")
VHFHelperEventBus = EventBus.new()
VHFHelperEventOnFrequencyChanged = "EventBus_EventName_VHFHelperEventOnFrequencyChanged"

local function activatePublicInterface()
	VHFHelperPublicInterface = {
		enterFrequencyProgrammaticallyAsString = function(newFullString)
			newFullString = validateFullFrequencyString(newFullString)
			if (newFullString ~= nil) then
				nextVhfFrequency = newFullString
			else
				nextVhfFrequency = emptyString
			end

			VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)

			return nextVhfFrequency
		end,
		isCurrentlyTunedIn = function(fullFrequencyString)
			newFullString = validateFullFrequencyString(fullFrequencyString)
			if (newFullString == nil) then
				return false
			end

			for c = 1, 2 do
				currentComString = tostring(currentVhfFrequencies[c])
				currentComString = currentComString:sub(1, 3) .. decimalCharacter .. currentComString:sub(4, 7)
				if (newFullString == currentComString) then
					return true
				end
			end

			return false
		end,
		isCurrentlyEntered = function(fullFrequencyString)
			newFullString = validateFullFrequencyString(fullFrequencyString)
			if (newFullString == nil) then
				return false
			end

			autocompletedNextVhf = autocompleteFrequencyString(nextVhfFrequency)

			if (newFullString == autocompletedNextVhf) then
				return true
			end

			return false
		end,
		isValidFrequency = function(fullFrequencyString)
			if (validateFullFrequencyString(fullFrequencyString) == nil) then
				return false
			else
				return true
			end
		end
	}
end

local function deactivatePublicInterface()
	VHFHelperPublicInterface = nil
end

local function windowVisibilityToInitialMacroState(windowIsVisible)
	if windowIsVisible then
		return "activate"
	else
		return "deactivate"
	end
end

local LuaIniParser = require("LIP")

local function fileExists(filePath)
	local file = io.open(filePath, "r")
	if file == nil then
		return false
	end

	io.close(file)
	return true
end

local ConfigurationClass
do
	Configuration = {}

	function Configuration:new(iniFilePath)
		local newInstanceWithState = {
			Path = iniFilePath,
			Content = {}
		}
		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function Configuration:load()
		if (not fileExists(self.Path)) then
			return
		end

		self.Content = LuaIniParser.load(self.Path)
	end

	function Configuration:save()
		LuaIniParser.save(self.Path, self.Content)
	end

	function Configuration:setValue(section, key, value)
		if (self.Content[section] == nil) then
			self.Content[section] = {}
		end
		if (type(value) == "string") then
			value = trim(value)
		end

		self.Content[section][key] = value
	end

	function Configuration:getValue(section, key, defaultValue)
		if (self.Content[section] == nil) then
			self.Content[section] = {}
		end
		if (self.Content[section][key]) == nil then
			self.Content[section][key] = defaultValue
		end

		return self.Content[section][key]
	end
end

local Config = Configuration:new(SCRIPT_DIRECTORY .. "vhf_helper.ini")

local windowVisibilityVisible = "visible"
local windowVisibilityHidden = "hidden"

local InterchangeLinkedDatarefClass
do
	InterchangeLinkedDataref = {
		Constants = {
			DatarefTypeInteger = "Int",
			DatarefAccessTypeWritable = "writable",
			DatarefAccessTypeReadable = "readable"
		}
	}
	function InterchangeLinkedDataref:new(
		newDataType,
		newInterchangeDatarefName,
		newInterchangeVariableName,
		newLinkedDatarefName,
		newLinkedReadVariableName,
		newOnInterchangeChangeFunction,
		newOnLinkedChangeFunction,
		newIsNewValueValidFunction)
		local newValue = nil

		local newInstanceWithState = {
			dataType = newDataType,
			interchangeDatarefName = newInterchangeDatarefName,
			interchangeVariableName = newInterchangeVariableName,
			linkedDatarefName = newLinkedDatarefName,
			linkedReadVariableName = newLinkedReadVariableName,
			getInterchangeValueFunction = loadstring("return " .. newInterchangeVariableName),
			getLinkedValueFunction = loadstring("return " .. newLinkedReadVariableName),
			onInterchangeChangeFunction = newOnInterchangeChangeFunction,
			onLinkedChangeFunction = newOnLinkedChangeFunction,
			isNewValueValidFunction = newIsNewValueValidFunction,
			lastLinkedValue = nil,
			lastInterchangeValue = nil,
			linkedDatarefWriteHandle = nil
		}

		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function InterchangeLinkedDataref:initialize()
		define_shared_DataRef(self.interchangeDatarefName, self.dataType)
		dataref(self.interchangeVariableName, self.interchangeDatarefName, self.Constants.DatarefAccessTypeWritable)

		dataref(self.linkedReadVariableName, self.linkedDatarefName, self.Constants.DatarefAccessTypeReadable)
		self.linkedDatarefWriteHandle = XPLMFindDataRef(self.linkedDatarefName)

		local linkedValue = self.getLinkedValueFunction()
		self.lastLinkedValue = linkedValue
		self.lastInterchangeValue = linkedValue
		self:_setInterchangeValue(linkedValue)
	end

	function InterchangeLinkedDataref:loopUpdate()
		local currentInterchangeValue = self:getInterchangeValue()
		if (currentInterchangeValue ~= self.lastInterchangeValue) then
			if (not self.isNewValueValidFunction(self, currentInterchangeValue)) then
				currentInterchangeValue = self:getLinkedValue()
				self:_setInterchangeValue(currentInterchangeValue)
			end

			self.onInterchangeChangeFunction(self, currentInterchangeValue)
			self:_setLinkedValue(currentInterchangeValue)
			self.lastInterchangeValue = currentInterchangeValue
		end

		local currentLinkedValue = self:getLinkedValue()
		if (currentLinkedValue ~= self.lastLinkedValue) then
			self.onLinkedChangeFunction(self, currentLinkedValue)
			self.lastLinkedValue = currentLinkedValue
		end
	end

	function InterchangeLinkedDataref:emitNewValue(value)
		self:_setInterchangeValue(value)
		self:_setLinkedValue(value)
	end

	function InterchangeLinkedDataref:getLinkedValue()
		return self.getLinkedValueFunction()
	end

	function InterchangeLinkedDataref:getInterchangeValue()
		return self.getInterchangeValueFunction()
	end

	function InterchangeLinkedDataref:isLocalLinkedDatarefAvailable()
		return XPLMFindDataRef(self.linkedDatarefName)
	end

	function InterchangeLinkedDataref:_setInterchangeValue(value)
		local setInterchangeValueFunction = loadstring(self.interchangeVariableName .. " = " .. value)
		setInterchangeValueFunction()
	end

	function InterchangeLinkedDataref:_setLinkedValue(value)
		XPLMSetDatai(self.linkedDatarefWriteHandle, value)
	end
end

local onComInterchangeChange = function(ild, newInterchangeValue)
	-- TODO: Find out if this works as expected:
	-- Emit change solely based on the user having pressed a button, especially if the new frequency is equal.
	-- Any real change will emit an event later anyway.
	-- if (ild:getLinkedValue() == newInterchangeValue) then
	-- 	VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
	-- end
end

local onComLinkedChanged = function(ild, newLinkedValue)
	VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

local isNewComFrequencyValid = function(ild, newValue)
	-- Workaround FlyWithLua/X-Plane bug:
	-- After creating a shared new dataref (and setting its inital value) the writable dataref variable is being assigned a
	-- random value (very likely straight from memory) after waiting a few frames.
	-- To workaround, ignore invalid values and continue using local com frequency values (which are supposed to be valid at this time).
	local freqString = tostring(newValue)
	local freqFullString = freqString:sub(1, 3) .. decimalCharacter .. freqString:sub(4, 6)
	if (not validateFullFrequencyString(freqFullString)) then
		printLogMessage(
			("Warning: Interchange frequency %s has been externally assigned an invalid value=%s. " ..
				"This is very likely happening during initialization and is a known issue in FlyWithLua/X-Plane dataref handling. " ..
					"If this happens during flight, something is seriously wrong."):format(ild.interchangeDatarefName, freqFullString)
		)
		return false
	end

	return true
end

-- Pre-defined dataref handles cannot be in a table :-/
InterchangeCOM1Frequency = 0
InterchangeCOM2Frequency = 0

COM1FrequencyRead = 0
COM2FrequencyRead = 0

local COMLinkedDatarefs = {
	InterchangeLinkedDataref:new(
		InterchangeLinkedDataref.Constants.DatarefTypeInteger,
		"VHFHelper/InterchangeCOM1Frequency",
		"InterchangeCOM1Frequency",
		"sim/cockpit2/radios/actuators/com1_frequency_hz_833",
		"COM1FrequencyRead",
		onComInterchangeChange,
		onComLinkedChanged,
		isNewComFrequencyValid
	),
	InterchangeLinkedDataref:new(
		InterchangeLinkedDataref.Constants.DatarefTypeInteger,
		"VHFHelper/InterchangeCOM2Frequency",
		"InterchangeCOM2Frequency",
		"sim/cockpit2/radios/actuators/com2_frequency_hz_833",
		"COM2FrequencyRead",
		onComInterchangeChange,
		onComLinkedChanged,
		isNewComFrequencyValid
	)
}

local function addToNextVhfFrequency(nextCharacter)
	if (string.len(nextVhfFrequency) == 7) then
		return
	end

	if (string.len(nextVhfFrequency) == 3) then
		nextVhfFrequency = nextVhfFrequency .. "."
	end

	nextVhfFrequency = nextVhfFrequency .. nextCharacter
end

local function nextVhfFrequencyCanBeSetNow()
	return (nextVhfFrequency:len() > 3)
end

local function removeLastCharacterFromNextVhfFrequency()
	nextVhfFrequency = nextVhfFrequency:sub(1, -2)
	if (string.len(nextVhfFrequency) == 4) then
		nextVhfFrequency = nextVhfFrequency:sub(1, -2)
	end

	VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

local function resetNextFrequency()
	nextVhfFrequency = emptyString
	VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

-- local function updateCurrentVhfFrequenciesFromPlane()
-- 	currentVhfFrequencies[1] = COM1FrequencyRead
-- 	currentVhfFrequencies[2] = COM2FrequencyRead
-- end

-- local function setPlaneVHFFrequency(comNumber, newFrequency)
-- 	XPLMSetDatai(vhfFrequencyWriteHandles[comNumber], newFrequency)

-- 	if (comNumber == 1) then
-- 		InterchangeCOM1Frequency = newFrequency
-- 	elseif (comNumber == 2) then
-- 		InterchangeCOM2Frequency = newFrequency
-- 	end

-- 	lastInterchangeFrequencies[comNumber] = newFrequency

-- 	if (currentVhfFrequencies[comNumber] == newFrequency) then
-- 		VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
-- 	end
-- end

local function validateAndSetNextVHFFrequency(comNumber)
	if (not nextVhfFrequencyCanBeSetNow()) then
		return
	end

	local cleanVhfFrequency = autocompleteFrequencyString(nextVhfFrequency):gsub("%.", "")
	local nextFrequencyAsNumber = tonumber(cleanVhfFrequency)

	COMLinkedDatarefs[comNumber]:emitNewValue(nextFrequencyAsNumber)

	-- TODO: Check if that works as expected in real FlyWithLua.
	-- setPlaneVHFFrequency(comNumber, nextFrequencyAsNumber)

	-- Emit change solely based on the user having pressed a button, especially if the new frequency is equal.
	-- Any real change will emit an event later anyway.
	if (COMLinkedDatarefs[comNumber]:getLinkedValue() == newFrequency) then
		VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
	end

	nextVhfFrequency = emptyString
end

local function getValidNumberCharacterOrUnderscoreInDefaultAirband(frequencyEnteredSoFar, number)
	if (string.len(frequencyEnteredSoFar) == 7) then
		return underscoreCharacter
	end

	character = tostring(number)
	freqStringLength = string.len(frequencyEnteredSoFar)

	if (freqStringLength == 0) then
		if (number ~= 1) then
			character = underscoreCharacter
		end
	elseif (freqStringLength == 1) then
		if (number < 1 or number > 3) then
			character = underscoreCharacter
		end
	elseif (freqStringLength == 2) then
		majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
		if (majorTenDigit == "1") then
			if (number < 8) then
				character = underscoreCharacter
			end
		elseif (majorTenDigit == "3") then
			if (number > 6) then
				character = underscoreCharacter
			end
		end
	elseif (freqStringLength == 5) then
		minorHundredDigit = frequencyEnteredSoFar:sub(5, 5)
		if (minorHundredDigit == "9") then
			if (number > 7) then
				character = underscoreCharacter
			end
		end
	elseif (freqStringLength == 6) then
		if (number ~= 0 and number ~= 5) then
			character = underscoreCharacter
		end

		minorTenDigit = frequencyEnteredSoFar:sub(6, 6)

		if ((minorTenDigit == "2" or minorTenDigit == "7") and number == 0) then
			character = underscoreCharacter
		elseif ((minorTenDigit == "4" or minorTenDigit == "9") and number == 5) then
			character = underscoreCharacter
		end
	end

	return character
end

local function getValidNumberCharacterOrUnderscore(number)
	return getValidNumberCharacterOrUnderscoreInDefaultAirband(nextVhfFrequency, number)
end

local globalFontScale = nil
local defaultDummySize = nil

local function createNumberButtonAndReactToClicks(number)
	numberCharacter = getValidNumberCharacterOrUnderscore(number)

	if (imgui.Button(numberCharacter, defaultDummySize, defaultDummySize) and numberCharacter ~= underscoreCharacter) then
		addToNextVhfFrequency(numberCharacter)
		VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
	end
end

local Colors = {
	a320Orange = 0xFF00AAFF,
	a320Blue = 0xFFFFDDAA,
	a320Green = 0xFF00AA00,
	white = 0xFFFFFFFF,
	black = 0xFF000000,
	defaultImguiBackground = 0xFF121110
}

local fullyPaddedFreqString = "___.___"

local function buildCurrentVhfLine(comNumber, nextVhfFrequencyIsSettable)
	imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

	imgui.TextUnformatted("COM" .. tonumber(comNumber) .. ": ")

	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Orange)

	currentVhfString = tostring(COMLinkedDatarefs[comNumber]:getLinkedValue())
	imgui.TextUnformatted(currentVhfString:sub(1, 3) .. decimalCharacter .. currentVhfString:sub(4, 7))
	imgui.PopStyleColor()

	imgui.PushStyleColor(imgui.constant.Col.Button, Colors.a320Green)

	if (nextVhfFrequencyIsSettable) then
		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.black)
	else
		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.white)
	end

	imgui.SameLine()
	imgui.TextUnformatted(" ")

	local buttonText = "   "
	if (nextVhfFrequencyIsSettable) then
		buttonText = "<" .. tonumber(comNumber) .. ">"

		imgui.SameLine()
		if (imgui.Button(buttonText)) then
			validateAndSetNextVHFFrequency(comNumber)
		end
	end

	imgui.PopStyleColor()
	imgui.PopStyleColor()

	imgui.PopStyleVar()
end

function buildVhfHelperWindow()
	imgui.SetWindowFontScale(1.0 * globalFontScale)

	nextVhfFrequencyIsSettable = nextVhfFrequencyCanBeSetNow()

	imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)

	buildCurrentVhfLine(1, nextVhfFrequencyIsSettable)
	buildCurrentVhfLine(2, nextVhfFrequencyIsSettable)

	imgui.TextUnformatted("Next VHF: ")

	if (nextVhfFrequencyCanBeSetNow()) then
		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Orange)
	else
		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Blue)
	end

	imgui.SameLine()

	paddedFreqString = nextVhfFrequency .. fullyPaddedFreqString:sub(string.len(nextVhfFrequency) + 1, 7)
	imgui.TextUnformatted(paddedFreqString)

	imgui.PopStyleVar()

	imgui.PopStyleColor()

	imgui.Dummy(defaultDummySize, defaultDummySize)
	imgui.SameLine()

	if (imgui.Button("Clear")) then
		resetNextFrequency()
	end

	imgui.SameLine()

	if (imgui.Button("Bksp")) then
		removeLastCharacterFromNextVhfFrequency()
	end

	imgui.Dummy(defaultDummySize, defaultDummySize)
	imgui.SameLine()

	imgui.SetWindowFontScale(1.3 * globalFontScale)

	imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Blue)

	for i = 1, 9 do
		createNumberButtonAndReactToClicks(i)

		if (i % 3 ~= 0) then
			imgui.SameLine()
		else
			imgui.Dummy(defaultDummySize, defaultDummySize)
			imgui.SameLine()
		end
	end

	imgui.Dummy(defaultDummySize, defaultDummySize)
	imgui.SameLine()

	createNumberButtonAndReactToClicks(0)

	imgui.PopStyleColor()
end

vhfHelperMainWindow = nil

function destroyVhfHelperWindow()
	if (vhfHelperMainWindow) then
		float_wnd_destroy(vhfHelperMainWindow)
		vhfHelperMainWindow = nil
	end

	Config:setValue("Windows", "MainWindowVisibility", windowVisibilityHidden)
	Config:save()

	deactivatePublicInterface()
end

VHFHelperIsInitialized = false

local vhfHelperLoopSingleton
do
	vhfHelperLoop = {}

	function vhfHelperLoop:initializeOnce()
		create_command("FlyWithLua/VHF Helper/ToggleWindow", "Toggle VHF Helper Window", "toggleVhfHelperWindow()", "", "")

		Config:load()

		local windowIsSupposedToBeVisible = false
		if (trim(Config:getValue("Windows", "MainWindowVisibility", windowVisibilityVisible)) == windowVisibilityVisible) then
			windowIsSupposedToBeVisible = true
		end

		add_macro(
			"VHF Helper",
			"createVhfHelperWindow()",
			"destroyVhfHelperWindow()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)

		do_often("vhfHelperLoop:tryInitLoopFunction()")
	end

	function vhfHelperLoop:tryInitLoopFunction()
		if (VHFHelperIsInitialized) then
			return
		end

		if
			(not COMLinkedDatarefs[1]:isLocalLinkedDatarefAvailable() or not COMLinkedDatarefs[2]:isLocalLinkedDatarefAvailable())
		 then
			return
		end

		COMLinkedDatarefs[1]:initialize()
		COMLinkedDatarefs[2]:initialize()

		do_every_frame("vhfHelperLoop:everyFrameLoopFunction()")

		VHFHelperIsInitialized = true
	end

	function vhfHelperLoop:everyFrameLoopFunction()
		if (not VHFHelperIsInitialized) then
			return
		end

		COMLinkedDatarefs[1]:loopUpdate()
		COMLinkedDatarefs[2]:loopUpdate()
	end
end

local defaultMacroName = "VHF Helper"
local defaultWindowName = "VHF Helper"

function createVhfHelperWindow()
	vhfHelperLoop:tryInitLoopFunction()

	local minWidthWithoutScrollbars = nil
	local minHeightWithoutScrollbars = nil

	globalFontScaleDescriptor = trim(Config:getValue("Windows", "GlobalFontScale", "big"))
	if (globalFontScaleDescriptor == "huge") then
		globalFontScale = 3.0
		minWidthWithoutScrollbars = 375
		minHeightWithoutScrollbars = 460
	elseif (globalFontScaleDescriptor == "big") then
		globalFontScale = 2.0
		minWidthWithoutScrollbars = 255
		minHeightWithoutScrollbars = 320
	else
		globalFontScale = 1.0
		minWidthWithoutScrollbars = 145
		minHeightWithoutScrollbars = 180
	end

	defaultDummySize = 20.0 * globalFontScale

	vhfHelperMainWindow = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
	float_wnd_set_title(vhfHelperMainWindow, defaultWindowName)
	float_wnd_set_imgui_builder(vhfHelperMainWindow, "buildVhfHelperWindow")
	float_wnd_set_onclose(vhfHelperMainWindow, "destroyVhfHelperWindow")

	Config:setValue("Windows", "MainWindowVisibility", windowVisibilityVisible)
	Config:save()

	activatePublicInterface()
end

local function showVhfHelperWindow(value)
	if (vhfHelperMainWindow == nil and value) then
		createVhfHelperWindow()
	elseif (vhfHelperMainWindow ~= nil and not value) then
		destroyVhfHelperWindow()
	end
end

local function toggleVhfHelperWindow()
	showVhfHelperWindow(vhfHelperMainWindow and true or false)
end

vhfHelperLoop:initializeOnce()

vhfHelperPackageExport = {}

vhfHelperPackageExport.test = {}
vhfHelperPackageExport.test.validateFullFrequencyString = validateFullFrequencyString
vhfHelperPackageExport.test.autocompleteFrequencyString = autocompleteFrequencyString
vhfHelperPackageExport.test.activatePublicInterface = activatePublicInterface
vhfHelperPackageExport.test.deactivatePublicInterface = deactivatePublicInterface
vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscore = getValidNumberCharacterOrUnderscore
vhfHelperPackageExport.test.getValidNumberCharacterOrUnderscoreInDefaultAirband =
	getValidNumberCharacterOrUnderscoreInDefaultAirband

vhfHelperPackageExport.test.Config = Config
vhfHelperPackageExport.test.defaultMacroName = defaultMacroName
vhfHelperPackageExport.test.defaultWindowName = defaultWindowName
vhfHelperPackageExport.test.COMLinkedDatarefs = COMLinkedDatarefs

-- When returning anything besides nothing, FlyWithLua does not expose global fields
return
