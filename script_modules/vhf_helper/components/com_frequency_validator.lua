local FrequencyValidator = require("vhf_helper.components.frequency_validator")
local Globals = require("vhf_helper.globals")

local ComFrequencyValidator
do
    ComFrequencyValidator = FrequencyValidator:new()

    TRACK_ISSUE("Feature", "Validate 123.4 as well, not only full frequency strings")
    Globals.OVERRIDE(ComFrequencyValidator.validate)
    function ComFrequencyValidator:validate(fullFrequencyString)
        local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 118000, 136975)
        if (cleanFrequencyString == nil) then
            return nil
        end

        local minorOneDigit = cleanFrequencyString:sub(6, 6)
        local minorTenDigit = cleanFrequencyString:sub(5, 5)
        if (minorOneDigit ~= "0" and minorOneDigit ~= "5") then
            minorOneDigit = "0"
            cleanFrequencyString = replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
        end

        if (minorTenDigit == "2" or minorTenDigit == "7") then
            local minorOneDigit = "5"
            cleanFrequencyString = Globals.replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
        end

        return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
    end

    Globals.OVERRIDE(ComFrequencyValidator.autocomplete)
    function ComFrequencyValidator:autocomplete(partialFrequencyString)
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

    TRACK_ISSUE("Tech Debt", "Is this override necessary? Seems it breaks without, but it probably should't")
    Globals.OVERRIDE(ComFrequencyValidator.getValidNumberCharacterOrNil)
    function ComFrequencyValidator:getValidNumberCharacterOrNil(frequencyEnteredSoFar, number)
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
            if (number < 1 or number > 3) then
                character = nil
            end
        elseif (freqStringLength == 2) then
            majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
            if (majorTenDigit == "1") then
                if (number < 8) then
                    character = nil
                end
            elseif (majorTenDigit == "3") then
                if (number > 6) then
                    character = nil
                end
            end
        elseif (freqStringLength == 5) then
            minorHundredDigit = frequencyEnteredSoFar:sub(5, 5)
            if (minorHundredDigit == "9") then
                if (number > 7) then
                    character = nil
                end
            end
        elseif (freqStringLength == 6) then
            if (number ~= 0 and number ~= 5) then
                character = nil
            end

            minorTenDigit = frequencyEnteredSoFar:sub(6, 6)

            if ((minorTenDigit == "2" or minorTenDigit == "7") and number == 0) then
                character = nil
            elseif ((minorTenDigit == "4" or minorTenDigit == "9") and number == 5) then
                character = nil
            end
        end

        return character
    end
end

return ComFrequencyValidator
