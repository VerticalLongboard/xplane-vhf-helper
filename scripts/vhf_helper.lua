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

--]] local emptyString =
	""
local decimalCharacter = "."
local underscoreCharacter = "_"

local function printLogMessage(messageString)
	logMsg(("VHF Helper: %s"):format(messageString or "NIL"))
end

local licensesOfDependencies = {
	{
		"Lua INI Parser",
		"MIT License",
		"https://github.com/Dynodzzo/Lua_INI_Parser"
	},
	{
		"Lua Event Bus",
		"MIT License",
		"https://github.com/prabirshrestha/lua-eventbus"
	},
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

local function OVERRIDE(overriddenFunction)
	assert(overriddenFunction)
end

local function NOOVRIDE(overriddenFunction)
	assert(overriddenFunction == nil)
end

local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end
local function replaceCharacter(str, pos, newCharacter)
	return str:sub(1, pos - 1) .. newCharacter .. str:sub(pos + 1)
end

local nextVhfFrequency = emptyString

local FrequencyValidatorClass
do
	FrequencyValidator = {}

	function FrequencyValidator:new()
		local newInstanceWithState = {}

		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function FrequencyValidator:validate(fullString)
		assert(nil)
	end

	function FrequencyValidator:autocomplete(partialString)
		assert(nil)
	end

	function FrequencyValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
		assert(nil)
	end
end

local COMFrequencyValidatorClass
do
	COMFrequencyValidator = FrequencyValidator:new()

	OVERRIDE(COMFrequencyValidator.validate)
	function COMFrequencyValidator:validate(fullFrequencyString)
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

	OVERRIDE(COMFrequencyValidator.autocomplete)
	function COMFrequencyValidator:autocomplete(partialFrequencyString)
		nextStringLength = partialFrequencyString:len()
		if (nextStringLength == 5) then
			partialFrequencyString = partialFrequencyString .. "00"
		elseif (nextStringLength == 6) then
			minorTenDigit = partialFrequencyString:sub(6, 6)
			if (minorTenDigit == "2" or minorTenDigit == "7") then
				partialFrequencyString = partialFrequencyString .. "5"
			else
				partialFrequencyString = partialFrequencyString .. "0"
			end
		end

		return partialFrequencyString
	end

	OVERRIDE(COMFrequencyValidator.getValidNumberCharacterOrUnderscore)
	function COMFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
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
end

local comFrequencyValidator = COMFrequencyValidator:new()

local NAVFrequencyValidatorClass
do
	NAVFrequencyValidator = FrequencyValidator:new()

	OVERRIDE(NAVFrequencyValidator.validate)
	function NAVFrequencyValidator:validate(fullFrequencyString)
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
		minVhfFrequency = 108000
		maxVhfFrequency = 117950
		if (frequencyNumber < minVhfFrequency or frequencyNumber > maxVhfFrequency) then
			return nil
		end

		minorTenDigit = cleanFrequencyString:sub(5, 5)
		if (minorTenDigit ~= "0" and minorTenDigit ~= "5") then
			return nil
		end

		minorOneDigit = cleanFrequencyString:sub(6, 6)
		if (minorOneDigit ~= "0") then
			return nil
		end

		return cleanFrequencyString:sub(1, 3) .. decimalCharacter .. cleanFrequencyString:sub(4, 7)
	end

	OVERRIDE(NAVFrequencyValidator.autocomplete)
	function NAVFrequencyValidator:autocomplete(partialFrequencyString)
		nextStringLength = partialFrequencyString:len()
		if (nextStringLength == 5) then
			partialFrequencyString = partialFrequencyString .. "00"
		elseif (nextStringLength == 6) then
			partialFrequencyString = partialFrequencyString .. "0"
		end

		return partialFrequencyString
	end

	OVERRIDE(NAVFrequencyValidator.getValidNumberCharacterOrUnderscore)
	function NAVFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
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
			if (number > 1) then
				character = underscoreCharacter
			end
		elseif (freqStringLength == 2) then
			majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
			if (majorTenDigit == "0") then
				if (number < 8) then
					character = underscoreCharacter
				end
			elseif (majorTenDigit == "1") then
				if (number > 7) then
					character = underscoreCharacter
				end
			end
		elseif (freqStringLength == 5) then
			majorTenDigit = frequencyEnteredSoFar:sub(5, 5)
			if (majorTenDigit == "9") then
				if (number > 5) then
					character = underscoreCharacter
				end
			end
		elseif (freqStringLength == 6) then
			if (number ~= 0 and number ~= 5) then
				character = underscoreCharacter
			end
		end

		return character
	end
end

local navFrequencyValidator = NAVFrequencyValidator:new()

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
			onInterchangeChangeFunction = newOnInterchangeChangeFunction,
			onLinkedChangeFunction = newOnLinkedChangeFunction,
			isNewValueValidFunction = newIsNewValueValidFunction,
			lastLinkedValue = nil,
			lastInterchangeValue = nil,
			linkedDatarefWriteHandle = nil,
			getInterchangeValueFunction = loadstring("return " .. newInterchangeVariableName),
			getLinkedValueFunction = loadstring("return " .. newLinkedReadVariableName)
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
end

local onComLinkedChanged = function(ild, newLinkedValue)
	VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

local isNewComFrequencyValid = function(ild, newValue)
	-- FlyWithLua Issue:
	-- After creating a shared new dataref (and setting its inital value) the writable dataref variable is being assigned a
	-- random value (very likely straight from memory) after waiting a few frames.
	-- To workaround, ignore invalid values and continue using local COM frequency values (which are supposed to be valid at this time).
	local freqString = tostring(newValue)
	local freqFullString = freqString:sub(1, 3) .. decimalCharacter .. freqString:sub(4, 6)
	if (not comFrequencyValidator:validate(freqFullString)) then
		printLogMessage(
			("Warning: Interchange frequency %s has been externally assigned an invalid value=%s. " ..
				"This is very likely happening during initialization and is a known issue in FlyWithLua/X-Plane dataref handling. " ..
					"If this happens during flight, something is seriously wrong."):format(ild.interchangeDatarefName, freqFullString)
		)
		return false
	end

	return true
end

-- FlyWithLua Issue: Pre-defined dataref handles cannot be in a table :-/
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

local onNavInterchangeChange = function(ild, newInterchangeValue)
end

local onNavLinkedChanged = function(ild, newLinkedValue)
end

local isNewNavFrequencyValid = function(ild, newValue)
	return true
end

InterchangeNAV1Frequency = 0
InterchangeNAV2Frequency = 0

NAV1FrequencyRead = 0
NAV2FrequencyRead = 0

local NAVLinkedDatarefs = {
	InterchangeLinkedDataref:new(
		InterchangeLinkedDataref.Constants.DatarefTypeInteger,
		"VHFHelper/InterchangeNAV1Frequency",
		"InterchangeNAV1Frequency",
		"sim/cockpit2/radios/actuators/nav1_frequency_hz",
		"NAV1FrequencyRead",
		onNavInterchangeChange,
		onNavLinkedChanged,
		isNewNavFrequencyValid
	),
	InterchangeLinkedDataref:new(
		InterchangeLinkedDataref.Constants.DatarefTypeInteger,
		"VHFHelper/InterchangeNAV2Frequency",
		"InterchangeNAV2Frequency",
		"sim/cockpit2/radios/actuators/nav2_frequency_hz",
		"NAV2FrequencyRead",
		onNavInterchangeChange,
		onNavLinkedChanged,
		isNavComFrequencyValid
	)
}

local allLinkedDatarefs = {COMLinkedDatarefs[1], COMLinkedDatarefs[2], NAVLinkedDatarefs[1], NAVLinkedDatarefs[2]}

VHFHelperPublicInterface = nil
local EventBus = require("eventbus")
VHFHelperEventBus = EventBus.new()
VHFHelperEventOnFrequencyChanged = "EventBus_EventName_VHFHelperEventOnFrequencyChanged"

local function activatePublicInterface()
	VHFHelperPublicInterface = {
		enterFrequencyProgrammaticallyAsString = function(newFullString)
			newFullString = comFrequencyValidator:validate(newFullString)

			local nextVhfFrequency = nil
			if (newFullString ~= nil) then
				nextVhfFrequency = newFullString
			else
				nextVhfFrequency = emptyString
			end

			ComFrequencyPanel:overrideEnteredValue(nextVhfFrequency)
			return nextVhfFrequency
		end,
		isCurrentlyTunedIn = function(fullFrequencyString)
			newFullString = comFrequencyValidator:validate(fullFrequencyString)
			if (newFullString == nil) then
				return false
			end

			for c = 1, 2 do
				currentComString = tostring(COMLinkedDatarefs[c]:getLinkedValue())
				currentComString = currentComString:sub(1, 3) .. decimalCharacter .. currentComString:sub(4, 7)
				if (newFullString == currentComString) then
					return true
				end
			end

			return false
		end,
		isCurrentlyEntered = function(fullFrequencyString)
			newFullString = comFrequencyValidator:validate(fullFrequencyString)
			if (newFullString == nil) then
				return false
			end

			autocompletedNextVhf = comFrequencyValidator:autocomplete(ComFrequencyPanel:getEnteredValue())

			if (newFullString == autocompletedNextVhf) then
				return true
			end

			return false
		end,
		isValidFrequency = function(fullFrequencyString)
			if (comFrequencyValidator:validate(fullFrequencyString) == nil) then
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
		local newInstanceWithState = {Path = iniFilePath, Content = {}}
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

local NumberSubPanelClass
do
	NumberSubPanel = {}

	function NumberSubPanel:new(newValidator)
		local newInstanceWithState = {
			enteredValue = emptyString,
			inputPanelValidator = newValidator
		}
		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function NumberSubPanel:getEnteredValue()
		return self.enteredValue
	end

	function NumberSubPanel:addCharacter(character)
		assert(nil)
	end

	function NumberSubPanel:numberCanBeSetNow()
		assert(nil)
	end

	function NumberSubPanel:backspace()
		assert(nil)
	end

	function NumberSubPanel:clear()
		self.enteredValue = emptyString
	end

	function NumberSubPanel:renderToCanvas()
		assert(nil)
	end
end

local globalFontScale = nil
local defaultDummySize = nil

local Colors = {
	a320Orange = 0xFF00AAFF,
	a320Blue = 0xFFFFDDAA,
	a320Green = 0xFF00AA00,
	white = 0xFFFFFFFF,
	black = 0xFF000000,
	defaultImguiBackground = 0xFF121110
}

local VhfFrequencySubPanelClass
do
	VhfFrequencySubPanel = NumberSubPanel:new()

	function VhfFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
		assert(nil)
	end

	function VhfFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
		assert(nil)
	end

	OVERRIDE(VhfFrequencySubPanel.new)
	function VhfFrequencySubPanel:new(newValidator, newFirstVhfLinkedDataref, newSecondVhfLinkedDataref, newDescriptor)
		local newInstanceWithState = NumberSubPanel:new(newValidator)

		newInstanceWithState.Constants = {FullyPaddedFreqString = "___.___"}
		newInstanceWithState.linkedDatarefs = {newFirstVhfLinkedDataref, newSecondVhfLinkedDataref}
		newInstanceWithState.descriptor = newDescriptor

		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	OVERRIDE(VhfFrequencySubPanel.addCharacter)
	function VhfFrequencySubPanel:addCharacter(character)
		if (string.len(self.enteredValue) == 7) then
			return
		end

		if (string.len(self.enteredValue) == 3) then
			self.enteredValue = self.enteredValue .. "."
		end

		self.enteredValue = self.enteredValue .. character
	end

	OVERRIDE(VhfFrequencySubPanel.numberCanBeSetNow)
	function VhfFrequencySubPanel:numberCanBeSetNow()
		return (self.enteredValue:len() > 3)
	end

	OVERRIDE(VhfFrequencySubPanel.backspace)
	function VhfFrequencySubPanel:backspace()
		self.enteredValue = self.enteredValue:sub(1, -2)
		if (string.len(nextVhfFrequency) == 4) then
			self.enteredValue = self.enteredValue:sub(1, -2)
		end
	end

	function VhfFrequencySubPanel:_buildCurrentVhfLine(vhfNumber, nextVhfFrequencyIsSettable)
		imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

		imgui.TextUnformatted(self.descriptor .. tonumber(vhfNumber) .. ": ")

		imgui.SameLine()
		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Orange)

		currentVhfString = self:_getCurrentCleanLinkedValueString(vhfNumber)
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
			buttonText = "<" .. tonumber(vhfNumber) .. ">"

			imgui.SameLine()
			if (imgui.Button(buttonText)) then
				self:_validateAndSetNextVHFFrequency(vhfNumber)
			end
		end

		imgui.PopStyleColor()
		imgui.PopStyleColor()

		imgui.PopStyleVar()
	end

	function VhfFrequencySubPanel:_createNumberButtonAndReactToClicks(number)
		numberCharacter = self.inputPanelValidator:getValidNumberCharacterOrUnderscore(self.enteredValue, number)

		if (imgui.Button(numberCharacter, defaultDummySize, defaultDummySize) and numberCharacter ~= underscoreCharacter) then
			self:addCharacter(numberCharacter)
		end
	end

	function VhfFrequencySubPanel:_validateAndSetNextVHFFrequency(vhfNumber)
		if (not self:numberCanBeSetNow()) then
			return
		end

		local cleanVhfFrequency = self.inputPanelValidator:autocomplete(self.enteredValue):gsub("%.", "")
		self:_setCleanLinkedValueString(vhfNumber, cleanVhfFrequency)

		self.enteredValue = emptyString
	end

	OVERRIDE(VhfFrequencySubPanel.renderToCanvas)
	function VhfFrequencySubPanel:renderToCanvas()
		imgui.SetWindowFontScale(1.0 * globalFontScale)

		local nextVhfFrequencyIsSettable = self:numberCanBeSetNow()

		imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)

		self:_buildCurrentVhfLine(1, nextVhfFrequencyIsSettable)
		self:_buildCurrentVhfLine(2, nextVhfFrequencyIsSettable)

		imgui.TextUnformatted("Next " .. self.descriptor .. ": ")

		if (nextVhfFrequencyIsSettable) then
			imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Orange)
		else
			imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Blue)
		end

		imgui.SameLine()

		paddedFreqString = self.enteredValue .. self.Constants.FullyPaddedFreqString:sub(string.len(self.enteredValue) + 1, 7)
		imgui.TextUnformatted(paddedFreqString)

		imgui.PopStyleVar()

		imgui.PopStyleColor()

		self:_renderNumberPanel()
	end

	function VhfFrequencySubPanel:_renderNumberPanel()
		imgui.Dummy(defaultDummySize, defaultDummySize)
		imgui.SameLine()

		if (imgui.Button("Clear")) then
			self:clear()
		end

		imgui.SameLine()

		if (imgui.Button("Bksp")) then
			self:backspace()
		end

		imgui.Dummy(defaultDummySize, defaultDummySize)
		imgui.SameLine()

		imgui.SetWindowFontScale(1.3 * globalFontScale)

		imgui.PushStyleColor(imgui.constant.Col.Text, Colors.a320Blue)

		for i = 1, 9 do
			self:_createNumberButtonAndReactToClicks(i)

			if (i % 3 ~= 0) then
				imgui.SameLine()
			else
				imgui.Dummy(defaultDummySize, defaultDummySize)
				imgui.SameLine()
			end
		end

		imgui.Dummy(defaultDummySize, defaultDummySize)
		imgui.SameLine()

		self:_createNumberButtonAndReactToClicks(0)

		imgui.PopStyleColor()
	end
end

local ComFrequencySubPanelClass
do
	ComFrequencySubPanel = VhfFrequencySubPanel:new()

	function ComFrequencySubPanel:overrideEnteredValue(newValue)
		self.enteredValue = newValue
		VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
	end

	OVERRIDE(ComFrequencySubPanel.addCharacter)
	function ComFrequencySubPanel:addCharacter(character)
		VhfFrequencySubPanel.addCharacter(self, character)
		VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
	end

	OVERRIDE(ComFrequencySubPanel.backspace)
	function ComFrequencySubPanel:backspace()
		local lenBefore = self.enteredValue:len()
		VhfFrequencySubPanel.backspace(self)
		if (lenBefore ~= self.enteredValue:len()) then
			VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
		end
	end

	OVERRIDE(ComFrequencySubPanel.clear)
	function ComFrequencySubPanel:clear()
		local lenBefore = self.enteredValue:len()
		VhfFrequencySubPanel.clear(self)
		if (lenBefore > 0) then
			VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
		end
	end

	OVERRIDE(ComFrequencySubPanel._getCurrentCleanLinkedValueString)
	function ComFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
		return tostring(self.linkedDatarefs[vhfNumber]:getLinkedValue())
	end

	OVERRIDE(ComFrequencySubPanel._setCleanLinkedValueString)
	function ComFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
		local nextFrequencyAsNumber = tonumber(cleanValueString)
		self.linkedDatarefs[vhfNumber]:emitNewValue(nextFrequencyAsNumber)

		-- Emit change solely based on the user having pressed a button, especially if the new frequency is equal.
		-- Any real change will emit an event later anyway.
		if (self.linkedDatarefs[vhfNumber]:getLinkedValue() == nextFrequencyAsNumber) then
			VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
		end
	end
end

local NavFrequencySubPanelClass
do
	NavFrequencySubPanel = VhfFrequencySubPanel:new()

	OVERRIDE(NavFrequencySubPanel._getCurrentCleanLinkedValueString)
	function NavFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
		return tostring(self.linkedDatarefs[vhfNumber]:getLinkedValue()) .. "0"
	end

	OVERRIDE(NavFrequencySubPanel._setCleanLinkedValueString)
	function NavFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
		cleanValueString = cleanValueString:sub(1, 5)
		local nextFrequencyAsNumber = tonumber(cleanVhfFrequency)
		self.linkedDatarefs[vhfNumber]:emitNewValue(nextFrequencyAsNumber)
	end
end

ComFrequencyPanel = ComFrequencySubPanel:new(comFrequencyValidator, COMLinkedDatarefs[1], COMLinkedDatarefs[2], "COM")
NavFrequencyPanel = NavFrequencySubPanel:new(navFrequencyValidator, NAVLinkedDatarefs[1], NAVLinkedDatarefs[2], "NAV")

-- FlyWithLua Issue: Functions passed to float_wnd_set_imgui_builder can only exist outside of tables :-/
function renderVhfHelperMainWindowToCanvas()
	vhfHelperMainWindow:renderToCanvas()
end

local vhfHelperMainWindowSingleton
do
	vhfHelperMainWindow = {
		Constants = {defaultWindowName = "VHF Helper"},
		window = nil
	}

	function vhfHelperMainWindow:create()
		vhfHelperLoop:tryInitialize()

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

		self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
		float_wnd_set_title(self.window, self.Constants.defaultWindowName)
		float_wnd_set_imgui_builder(self.window, "renderVhfHelperMainWindowToCanvas")
		float_wnd_set_onclose(self.window, "vhfHelperMainWindow:destroy")

		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityVisible)
		Config:save()

		activatePublicInterface()
	end

	function vhfHelperMainWindow:destroy()
		if (self.window) then
			float_wnd_destroy(self.window)
			window = nil
		end

		Config:setValue("Windows", "MainWindowVisibility", windowVisibilityHidden)
		Config:save()

		deactivatePublicInterface()
	end

	function vhfHelperMainWindow:show(value)
		if (self.window == nil and value) then
			self:create()
		elseif (self.window ~= nil and not value) then
			self:destroy()
		end
	end

	function vhfHelperMainWindow:toggle()
		self:show(window and true or false)
	end

	function vhfHelperMainWindow:renderToCanvas()
		-- TODO: Add buttons to change to NAV
		ComFrequencyPanel:renderToCanvas()
		imgui.TextUnformatted(currentTestString)
	end
end

local vhfHelperLoopSingleton
do
	vhfHelperLoop = {
		Constants = {defaultMacroName = "VHF Helper"},
		alreadyInitialized = false
	}

	function vhfHelperLoop:isInitialized()
		return self.alreadyInitialized
	end

	function vhfHelperLoop:bootstrap()
		Config:load()

		local windowIsSupposedToBeVisible = false
		if (trim(Config:getValue("Windows", "MainWindowVisibility", windowVisibilityVisible)) == windowVisibilityVisible) then
			windowIsSupposedToBeVisible = true
		end

		add_macro(
			self.Constants.defaultMacroName,
			"vhfHelperMainWindow:create()",
			"vhfHelperMainWindow:destroy()",
			windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
		)

		create_command(
			"FlyWithLua/VHF Helper/ToggleWindow",
			"Toggle VHF Helper Window",
			"vhfHelperMainWindow:toggle()",
			"",
			""
		)

		do_often("vhfHelperLoop:tryInitialize()")
	end

	function vhfHelperLoop:tryInitialize()
		if (self.alreadyInitialized) then
			return
		end

		if (not self:_canInitializeNow()) then
			return
		end

		self:_initializeNow()

		do_every_frame("vhfHelperLoop:everyFrameLoop()")
	end

	function vhfHelperLoop:everyFrameLoop()
		if (not self.alreadyInitialized) then
			return
		end

		for _, ldr in pairs(allLinkedDatarefs) do
			ldr:loopUpdate()
		end

		currentTestString = tostring(NAV1FrequencyRead)
	end

	function vhfHelperLoop:_canInitializeNow()
		for _, ldr in pairs(allLinkedDatarefs) do
			if (not ldr:isLocalLinkedDatarefAvailable()) then
				return false
			end
		end

		return true
	end

	function vhfHelperLoop:_initializeNow()
		for _, ldr in pairs(allLinkedDatarefs) do
			ldr:initialize()
		end

		self.alreadyInitialized = true
	end
end

vhfHelperLoop:bootstrap()

vhfHelperPackageExport = {}
vhfHelperPackageExport.test = {}
vhfHelperPackageExport.test.comFrequencyValidator = comFrequencyValidator
vhfHelperPackageExport.test.navFrequencyValidator = navFrequencyValidator
vhfHelperPackageExport.test.activatePublicInterface = activatePublicInterface
vhfHelperPackageExport.test.deactivatePublicInterface = deactivatePublicInterface
vhfHelperPackageExport.test.Config = Config
vhfHelperPackageExport.test.vhfHelperLoop = vhfHelperLoop
vhfHelperPackageExport.test.vhfHelperMainWindow = vhfHelperMainWindow
vhfHelperPackageExport.test.COMLinkedDatarefs = COMLinkedDatarefs

-- FlyWithLua Issue: When returning anything besides nothing, FlyWithLua does not expose global fields to other scripts
return
