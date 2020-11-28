local NumberValidator = require("vhf_helper.components.number_validator")
local Globals = require("vhf_helper.globals")

local BaroValidator
do
    BaroValidator = NumberValidator:new()

    Globals.OVERRIDE(BaroValidator.new)
    function BaroValidator:new()
        local newInstanceWithState = NumberValidator:new()
        newInstanceWithState.Constants = {
            -- https://en.wikipedia.org/wiki/Atmospheric_pressure
            MaxPressure = 1084,
            MinPressure = 870
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    Globals.OVERRIDE(BaroValidator.validate)
    function BaroValidator:validate(fullString)
        if (fullString == nil) then
            return nil
        end

        if (fullString:len() ~= 4) then
            return nil
        end

        local number = tonumber(fullString)
        if (number < self.Constants.MinPressure or number > self.Constants.MaxPressure) then
            return nil
        end

        return fullString
    end

    Globals.OVERRIDE(BaroValidator.autocomplete)
    function BaroValidator:autocomplete(partialString)
        if (partialString:len() < 4) then
            local firstDigit = partialString:sub(1, 1)
            if (firstDigit == "9") then
                partialString = "0" .. partialString
            end
        end

        for i = partialString:len(), 3 do
            partialString = partialString .. "0"
        end

        return partialString
    end
end

return BaroValidator
