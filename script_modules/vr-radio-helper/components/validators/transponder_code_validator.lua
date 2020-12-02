local NumberValidator = require("vr-radio-helper.components.validators.number_validator")
local Globals = require("vr-radio-helper.globals")

local TransponderCodeValidator
do
    TransponderCodeValidator = NumberValidator:new()

    Globals.OVERRIDE(TransponderCodeValidator.new)
    function TransponderCodeValidator:new()
        local newInstanceWithState = NumberValidator:new()
        newInstanceWithState.Constants = {
            MaxTransponderCode = 7777
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    Globals.OVERRIDE(TransponderCodeValidator.validate)
    function TransponderCodeValidator:validate(fullString)
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

    Globals.OVERRIDE(TransponderCodeValidator.autocomplete)
    function TransponderCodeValidator:autocomplete(partialString)
        for i = partialString:len(), 3 do
            partialString = partialString .. "0"
        end

        return partialString
    end
end

return TransponderCodeValidator
