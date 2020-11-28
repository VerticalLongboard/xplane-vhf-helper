local FrequencyValidator = require("vhf_helper.components.frequency_validator")
local Globals = require("vhf_helper.globals")

local NavFrequencyValidator
do
    NavFrequencyValidator = FrequencyValidator:new()

    Globals.OVERRIDE(NavFrequencyValidator.validate)
    function NavFrequencyValidator:validate(fullFrequencyString)
        local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 108000, 117950)
        if (cleanFrequencyString == nil) then
            return nil
        end

        local minorHundredDigit = cleanFrequencyString:sub(5, 5)
        if (minorHundredDigit ~= "0" and minorHundredDigit ~= "5") then
            return nil
        end

        local minorTenDigit = cleanFrequencyString:sub(6, 6)
        if (minorTenDigit ~= "0") then
            return nil
        end

        return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
    end

    Globals.OVERRIDE(NavFrequencyValidator.autocomplete)
    function NavFrequencyValidator:autocomplete(partialFrequencyString)
        local nextStringLength = partialFrequencyString:len()
        if (nextStringLength == 5) then
            partialFrequencyString = partialFrequencyString .. "00"
        elseif (nextStringLength == 6) then
            partialFrequencyString = partialFrequencyString .. "0"
        end

        return partialFrequencyString
    end

    TRACK_ISSUE("Tech Debt", "Is this override necessary?")
    Globals.OVERRIDE(NavFrequencyValidator.getValidNumberCharacterOrNil)
    function NavFrequencyValidator:getValidNumberCharacterOrNil(frequencyEnteredSoFar, number)
        if (string.len(frequencyEnteredSoFar) == 7) then
            return nil
        end

        local character = tostring(number)
        freqStringLength = string.len(frequencyEnteredSoFar)

        if (freqStringLength == 0) then
            if (number ~= 1) then
                character = nil
            end
        elseif (freqStringLength == 1) then
            if (number > 1) then
                character = nil
            end
        elseif (freqStringLength == 2) then
            majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
            if (majorTenDigit == "0") then
                if (number < 8) then
                    character = nil
                end
            elseif (majorTenDigit == "1") then
                if (number > 7) then
                    character = nil
                end
            end
        elseif (freqStringLength == 5) then
            if (number ~= 0 and number ~= 5) then
                character = nil
            end
        elseif (freqStringLength == 6) then
            if (number ~= 0) then
                character = nil
            end
        end

        return character
    end
end

return NavFrequencyValidator
