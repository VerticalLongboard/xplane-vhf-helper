Globals = require("vhf_helper.globals")
local NumberValidator = require("vhf_helper.components.number_validator")

local FrequencyValidator
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

return FrequencyValidator
