local NumberValidator = require("vhf_helper.components.number_validator")
local Globals = require("vhf_helper.globals")

local TransponderValidator
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

return TransponderValidator
