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

local currentVhfFrequencies = {
	0,
	0
}

local nextVhfFrequency = emptyString

local lastInterchangeFrequencies = {
	0,
	0
}

vhfFrequencyWriteHandles = {
	nil,
	nil
}

-- Pre-defined dataref handles cannot be in a table :-/
InterchangeVHF1Frequency = 0
InterchangeVHF2Frequency = 0

CurrentVHF1FrequencyRead = 0
CurrentVHF2FrequencyRead = 0

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
	return (string.len(nextVhfFrequency) > 3)
end

local function removeLastCharacterFromNextVhfFrequency()
	nextVhfFrequency = string.sub(nextVhfFrequency, 1, -2)
	if (string.len(nextVhfFrequency) == 4) then
		nextVhfFrequency = string.sub(nextVhfFrequency, 1, -2)
	end
end

local function resetNextFrequency()
	nextVhfFrequency = emptyString
end

local function updateCurrentVhfFrequenciesFromPlane()
	currentVhfFrequencies[1] = CurrentVHF1FrequencyRead
	currentVhfFrequencies[2] = CurrentVHF2FrequencyRead
end

local function setPlaneVHF1Frequency(newFrequency)
	XPLMSetDatai(vhfFrequencyWriteHandles[1], newFrequency)
	InterchangeVHF1Frequency = newFrequency
	lastInterchangeFrequencies[1] = newFrequency
end

local function setPlaneVHF2Frequency(newFrequency)
	XPLMSetDatai(vhfFrequencyWriteHandles[2], newFrequency)
	InterchangeVHF2Frequency = newFrequency
	lastInterchangeFrequencies[2] = newFrequency
end

local function autocompleteCleanFrequencyString(cleanVhfFrequencyString)
	nextStringLength = string.len(cleanVhfFrequencyString)
	if (nextStringLength == 4) then
		cleanVhfFrequencyString = cleanVhfFrequencyString .. "00"
	elseif (nextStringLength == 5) then
		minorTenDigit = string.sub(cleanVhfFrequencyString, 5, 5)
		if (minorTenDigit == "2" or minorTenDigit == "7") then
			cleanVhfFrequencyString = cleanVhfFrequencyString .. "5"
		else
			cleanVhfFrequencyString = cleanVhfFrequencyString .. "0"
		end
	end
	
	return cleanVhfFrequencyString
end

local function validateAndSetNextVHFFrequency(comNumber)
	if (not nextVhfFrequencyCanBeSetNow()) then
		return
	end

	cleanVhfFrequency = string.gsub(nextVhfFrequency, "%.", "")
	cleanVhfFrequency = autocompleteCleanFrequencyString(cleanVhfFrequency)
	nextFrequencyAsNumber = tonumber(cleanVhfFrequency)
	
	if (comNumber == 1) then
		setPlaneVHF1Frequency(nextFrequencyAsNumber)
	elseif (comNumber == 2) then
		setPlaneVHF2Frequency(nextFrequencyAsNumber)
	end
	
	nextVhfFrequency = emptyString
end

local function getValidNumberCharacterOrUnderscoreInDefaultAirband(number)
	if (string.len(nextVhfFrequency) == 7) then
		return underscoreCharacter
	end
		
	character = tostring(number);
	freqStringLength = string.len(nextVhfFrequency)
	
	if (freqStringLength == 0) then
		if (number ~= 1) then
			character = underscoreCharacter;
		end
	elseif (freqStringLength == 1) then
		if (number < 1 or number > 3) then
			character = underscoreCharacter;
		end
	elseif (freqStringLength == 2) then
		majorTenDigit = string.sub(nextVhfFrequency, 2, 2)
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
		minorHundredDigit = string.sub(nextVhfFrequency, 5, 5)
		if (minorHundredDigit == "9") then
			if (number > 7) then
				character = underscoreCharacter
			end
		end
	elseif (freqStringLength == 6) then
		if (number ~= 0 and number ~= 5) then
			character = underscoreCharacter;
		end
		
		minorTenDigit = string.sub(nextVhfFrequency, 6, 6)
		
		if ((minorTenDigit == "2" or minorTenDigit == "7") and number == 0) then
			character = underscoreCharacter
		elseif ((minorTenDigit == "4" or minorTenDigit == "9") and number == 5) then
			character = underscoreCharacter
		end
	end
	
	return character
end

local function getValidNumberCharacterOrUnderscore(number)
	return getValidNumberCharacterOrUnderscoreInDefaultAirband(number)
end

local defaultDummySize = 40.0

local function createNumberButtonAndReactToClicks(number)
	numberCharacter = getValidNumberCharacterOrUnderscore(number)
				
	if (imgui.Button(numberCharacter, defaultDummySize, defaultDummySize) and numberCharacter ~= underscoreCharacter) then
		addToNextVhfFrequency(numberCharacter)
	end
end

local a320Orange = 0xFF00AAFF
local a320Blue = 0xFFFFDDAA
local a320Green = 0xFF00AA00
local whiteColor = 0xFFFFFFFF
local fullyPaddedFreqString = "___.___"

local function buildCurrentVhfLine(comNumber, nextVhfFrequencyIsSettable)
	imgui.TextUnformatted("COM" .. tonumber(comNumber) .. ":")

	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Text, a320Orange)
	currentVhfString = tostring(currentVhfFrequencies[comNumber])
	imgui.TextUnformatted(string.sub(currentVhfString, 1, 3) .. decimalCharacter .. string.sub(currentVhfString, 4, 7))
	imgui.PopStyleColor()
	
	if (nextVhfFrequencyIsSettable) then
		imgui.PushStyleColor(imgui.constant.Col.Text, a320Green)
	else
		imgui.PushStyleColor(imgui.constant.Col.Text, whiteColor)
	end
	
	imgui.SameLine()
	
	buttonText = "___"
	if (nextVhfFrequencyIsSettable) then
		buttonText = "<" .. tonumber(comNumber) .. ">"
	end

	if (imgui.Button(buttonText)) then
		validateAndSetNextVHFFrequency(comNumber)
	end
	
	imgui.PopStyleColor()
end

function buildVhfHelperWindow()
	imgui.SetWindowFontScale(2.0)

	nextVhfFrequencyIsSettable = nextVhfFrequencyCanBeSetNow() --nextVhfFrequencyIsEnteredCompletely()
	
	buildCurrentVhfLine(1, nextVhfFrequencyIsSettable)
	buildCurrentVhfLine(2, nextVhfFrequencyIsSettable)
		
	imgui.TextUnformatted("Next VHF:")
	
	if (nextVhfFrequencyCanBeSetNow()) then
		imgui.PushStyleColor(imgui.constant.Col.Text, a320Orange)
	else
		imgui.PushStyleColor(imgui.constant.Col.Text, a320Blue)
	end
	
	imgui.SameLine()
	
	paddedFreqString = nextVhfFrequency .. string.sub(fullyPaddedFreqString, string.len(nextVhfFrequency) + 1, 7)
	imgui.TextUnformatted(paddedFreqString)
	
	imgui.PopStyleColor()
	
	imgui.Dummy(defaultDummySize * 1.9, defaultDummySize)
	imgui.SameLine()
	
	if (imgui.Button("Clear")) then
		resetNextFrequency()
	end
	
	imgui.SameLine()
	
	if (imgui.Button("Bksp")) then
		removeLastCharacterFromNextVhfFrequency()
	end
		
	imgui.SameLine()
	imgui.Dummy(defaultDummySize * 0.5, defaultDummySize * 0.5)
	
	imgui.Dummy(defaultDummySize, defaultDummySize)
	imgui.SameLine()
	
	imgui.SetWindowFontScale(3.0)
		
	imgui.PushStyleColor(imgui.constant.Col.Text, a320Blue)
		
	for i=1, 9 do
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

vhfHelperWindow = nil

function hideVhfHelperWindow()
	if (vhfHelperWindow) then
		float_wnd_destroy(vhfHelperWindow)
	end
end

function everyFrameLoopFunction()
	updateCurrentVhfFrequenciesFromPlane()
	
	currentInterchangeVhf1Freq = InterchangeVHF1Frequency;
	
	if (currentInterchangeVhf1Freq ~= lastInterchangeFrequencies[1]) then
		setPlaneVHF1Frequency(currentInterchangeVhf1Freq)
	end
	
	currentInterchangeVhf2Freq = InterchangeVHF2Frequency;
	
	if (currentInterchangeVhf2Freq ~= lastInterchangeFrequencies[2]) then
		setPlaneVHF2Frequency(currentInterchangeVhf2Freq)
	end
end

function showVhfHelperWindow()
	tryInitLoopFunction()
	
	minWidthWithoutScrollbars = 255
	minHeightWithoutScrollbars = 335
	
	vhfHelperWindow = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
	float_wnd_set_title(vhfHelperWindow, "VHF Helper")
	float_wnd_set_imgui_builder(vhfHelperWindow, "buildVhfHelperWindow")
	float_wnd_set_onclose(vhfHelperWindow, "hideVhfHelperWindow")
end

VHFHelperIsInitialized = false

local comVhfFrequencyDataRefNames = {
	"sim/cockpit2/radios/actuators/com1_frequency_hz_833",
	"sim/cockpit2/radios/actuators/com2_frequency_hz_833"
}

local interchangeFrequencyNames = {
	"VHFHelper/InterchangeVHF1Frequency",
	"VHFHelper/InterchangeVHF2Frequency"
}

function tryInitLoopFunction()
	if (VHFHelperIsInitialized) then
		return
	end
		
	if (not XPLMFindDataRef(comVhfFrequencyDataRefNames[1]) or not XPLMFindDataRef(comVhfFrequencyDataRefNames[2])) then
		return
	end
	
	dataref("CurrentVHF1FrequencyRead", comVhfFrequencyDataRefNames[1], "readable")
	vhfFrequencyWriteHandles[1] = XPLMFindDataRef(comVhfFrequencyDataRefNames[1])
	
	dataref("CurrentVHF2FrequencyRead", comVhfFrequencyDataRefNames[2], "readable")
	vhfFrequencyWriteHandles[2] = XPLMFindDataRef(comVhfFrequencyDataRefNames[2])
	
	do_every_frame("everyFrameLoopFunction()")
		
	updateCurrentVhfFrequenciesFromPlane()
	
	lastInterchangeFrequencies[1] = CurrentVHF1FrequencyRead
	InterchangeVHF1Frequency = CurrentVHF1FrequencyRead
	
	lastInterchangeFrequencies[2] = CurrentVHF2FrequencyRead
	InterchangeVHF2Frequency = CurrentVHF2FrequencyRead
	
	VHFHelperIsInitialized = true
end

add_macro("VHF Helper", "showVhfHelperWindow()", "hideVhfHelperWindow()", "deactivate")

InterchangeVHF1Frequency = define_shared_DataRef(interchangeFrequencyNames[1], "Int")
dataref("InterchangeVHF1Frequency", interchangeFrequencyNames[1], "writable")

InterchangeVHF2Frequency = define_shared_DataRef(interchangeFrequencyNames[2], "Int")
dataref("InterchangeVHF2Frequency", interchangeFrequencyNames[2], "writable")

do_often("tryInitLoopFunction()")
