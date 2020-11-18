local Globals = require("vhf_helper.globals")

local NumberValidatorClass
do
	NumberValidator = {}

	function NumberValidator:new()
		local newInstanceWithState = {}

		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	function NumberValidator:validate(fullString)
		assert(nil)
	end

	function NumberValidator:autocomplete(partialString)
		assert(nil)
	end

	function NumberValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
		assert(nil)
	end
end

local TransponderValidatorClass
do
	TransponderValidator = NumberValidator:new()

	Globals.OVERRIDE(TransponderValidator.new)
	function TransponderValidator:new()
		local newInstanceWithState = NumberValidator:new()
		newInstanceWithState.Constants = {
			MaxTransponderCode = 7777
		}
		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	Globals.OVERRIDE(TransponderValidator.validate)
	function TransponderValidator:validate(fullString)
		if (fullString == nil) then
			return nil
		end

		if (fullString:len() ~= 4) then
			return nil
		end

		local number = tonumber(fullString)
		if (number < 0 or number > self.Constants.MaxTransponderCode) then
			return nil
		end

		for i = 1, #fullString do
			if (tonumber(fullString:sub(i, i)) > 7) then
				return nil
			end
		end

		return fullString
	end

	Globals.OVERRIDE(TransponderValidator.autocomplete)
	function TransponderValidator:autocomplete(partialString)
		for i = partialString:len(), 3 do
			partialString = partialString .. "0"
		end

		return partialString
	end

	Globals.OVERRIDE(TransponderValidator.getValidNumberCharacterOrUnderscore)
	function TransponderValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
		local numberAsString = tostring(number)
		local afterEnteringNumber = stringEnteredSoFar .. numberAsString
		local autocompleted = self:autocomplete(afterEnteringNumber)
		if (self:validate(autocompleted) == nil) then
			return Globals.underscoreCharacter
		end

		return numberAsString
	end
end

local FrequencyValidatorClass
do
	FrequencyValidator = NumberValidator:new()

	Globals._NEWFUNC(FrequencyValidator._checkBasicValidity)
	function FrequencyValidator:_checkBasicValidity(fullFrequencyString, minVhf, maxVhf)
		if (fullFrequencyString == nil) then
			return nil
		end
		if (fullFrequencyString:len() ~= 7) then
			return nil
		end
		if (fullFrequencyString:sub(4, 4) ~= Globals.decimalCharacter) then
			return nil
		end

		local cleanFrequencyString = fullFrequencyString:sub(1, 3) .. fullFrequencyString:sub(5, 7)

		frequencyNumber = tonumber(cleanFrequencyString)
		if (frequencyNumber < minVhf or frequencyNumber > maxVhf) then
			return nil
		end

		return cleanFrequencyString
	end
end

local COMFrequencyValidatorClass
do
	COMFrequencyValidator = FrequencyValidator:new()

	Globals.OVERRIDE(COMFrequencyValidator.validate)
	function COMFrequencyValidator:validate(fullFrequencyString)
		local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 118000, 136975)
		if (cleanFrequencyString == nil) then
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
			cleanFrequencyString = Globals.replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
		end

		return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
	end

	Globals.OVERRIDE(COMFrequencyValidator.autocomplete)
	function COMFrequencyValidator:autocomplete(partialFrequencyString)
		local nextStringLength = partialFrequencyString:len()
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

	Globals.OVERRIDE(COMFrequencyValidator.getValidNumberCharacterOrUnderscore)
	function COMFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
		if (string.len(frequencyEnteredSoFar) == 7) then
			return Globals.underscoreCharacter
		end

		local character = tostring(number)
		freqStringLength = string.len(frequencyEnteredSoFar)

		if (freqStringLength == 0) then
			if (number ~= 1) then
				character = Globals.underscoreCharacter
			end
		elseif (freqStringLength == 1) then
			if (number < 1 or number > 3) then
				character = Globals.underscoreCharacter
			end
		elseif (freqStringLength == 2) then
			majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
			if (majorTenDigit == "1") then
				if (number < 8) then
					character = Globals.underscoreCharacter
				end
			elseif (majorTenDigit == "3") then
				if (number > 6) then
					character = Globals.underscoreCharacter
				end
			end
		elseif (freqStringLength == 5) then
			minorHundredDigit = frequencyEnteredSoFar:sub(5, 5)
			if (minorHundredDigit == "9") then
				if (number > 7) then
					character = Globals.underscoreCharacter
				end
			end
		elseif (freqStringLength == 6) then
			if (number ~= 0 and number ~= 5) then
				character = Globals.underscoreCharacter
			end

			minorTenDigit = frequencyEnteredSoFar:sub(6, 6)

			if ((minorTenDigit == "2" or minorTenDigit == "7") and number == 0) then
				character = Globals.underscoreCharacter
			elseif ((minorTenDigit == "4" or minorTenDigit == "9") and number == 5) then
				character = Globals.underscoreCharacter
			end
		end

		return character
	end
end

local NAVFrequencyValidatorClass
do
	NAVFrequencyValidator = FrequencyValidator:new()

	Globals.OVERRIDE(NAVFrequencyValidator.validate)
	function NAVFrequencyValidator:validate(fullFrequencyString)
		local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 108000, 117950)
		if (cleanFrequencyString == nil) then
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

		return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
	end

	Globals.OVERRIDE(NAVFrequencyValidator.autocomplete)
	function NAVFrequencyValidator:autocomplete(partialFrequencyString)
		local nextStringLength = partialFrequencyString:len()
		if (nextStringLength == 5) then
			partialFrequencyString = partialFrequencyString .. "00"
		elseif (nextStringLength == 6) then
			partialFrequencyString = partialFrequencyString .. "0"
		end

		return partialFrequencyString
	end

	Globals.OVERRIDE(NAVFrequencyValidator.getValidNumberCharacterOrUnderscore)
	function NAVFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
		if (string.len(frequencyEnteredSoFar) == 7) then
			return Globals.underscoreCharacter
		end

		local character = tostring(number)
		freqStringLength = string.len(frequencyEnteredSoFar)

		if (freqStringLength == 0) then
			if (number ~= 1) then
				character = Globals.underscoreCharacter
			end
		elseif (freqStringLength == 1) then
			if (number > 1) then
				character = Globals.underscoreCharacter
			end
		elseif (freqStringLength == 2) then
			majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
			if (majorTenDigit == "0") then
				if (number < 8) then
					character = Globals.underscoreCharacter
				end
			elseif (majorTenDigit == "1") then
				if (number > 7) then
					character = Globals.underscoreCharacter
				end
			end
		elseif (freqStringLength == 5) then
			if (number ~= 0 and number ~= 5) then
				character = Globals.underscoreCharacter
			end
		elseif (freqStringLength == 6) then
			if (number ~= 0) then
				character = Globals.underscoreCharacter
			end
		end

		return character
	end
end

local M = {}
M.bootstrap = function()
	M.transponderCodeValidator = TransponderValidator:new()
	M.comFrequencyValidator = COMFrequencyValidator:new()
	M.navFrequencyValidator = NAVFrequencyValidator:new()
end
return M
