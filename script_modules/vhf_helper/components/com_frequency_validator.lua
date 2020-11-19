require("vhf_helper.components.frequency_validator")

local COMFrequencyValidatorClass
do
    ComFrequencyValidator = FrequencyValidator:new()

    Globals.OVERRIDE(ComFrequencyValidator.validate)
    function ComFrequencyValidator:validate(fullFrequencyString)
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

    Globals.OVERRIDE(ComFrequencyValidator.getValidNumberCharacterOrUnderscore)
    function ComFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
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
