local FrequencyValidator = require("vhf_helper.components.frequency_validator")

local NavFrequencyValidator
do
    NavFrequencyValidator = FrequencyValidator:new()

    Globals.OVERRIDE(NavFrequencyValidator.validate)
    function NavFrequencyValidator:validate(fullFrequencyString)
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

    Globals.OVERRIDE(NavFrequencyValidator.getValidNumberCharacterOrUnderscore)
    function NavFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
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

return NavFrequencyValidator
