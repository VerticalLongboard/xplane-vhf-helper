local NumberValidator = require("vr-radio-helper.components.validators.number_validator")
local Globals = require("vr-radio-helper.globals")

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
        if (partialString:len() == 3) then
            local firstDigit = partialString:sub(1, 1)
            if (firstDigit == "0") then
                return partialString
            elseif (firstDigit == "8" or firstDigit == "9") then
                return "0" .. partialString
            end
        end

        return partialString
    end

    Globals.OVERRIDE(BaroValidator.getValidNumberCharacterOrNil)
    function BaroValidator:getValidNumberCharacterOrNil(stringEnteredSoFar, number)
        local character = tostring(number)
        if (stringEnteredSoFar:len() == 0) then
            if (number > 1 and number < 8) then
                character = nil
            end
        elseif (stringEnteredSoFar:len() > 0) then
            local globalFirstDigit = stringEnteredSoFar:sub(1, 1)
            local isBelowOneThousand = false
            local belowOneThousandBaseOffset = 0
            if (globalFirstDigit == "0") then
                isBelowOneThousand = true
                belowOneThousandBaseOffset = 1
            elseif (globalFirstDigit == "8" or globalFirstDigit == "9") then
                isBelowOneThousand = true
            end

            if (isBelowOneThousand) then
                --  |
                -- 0870
                -- 0980
                if (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 0) then
                    if (number < 8) then
                        character = nil
                    end
                elseif (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 1) then
                    local firstDigit =
                        stringEnteredSoFar:sub(1 + belowOneThousandBaseOffset, 1 + belowOneThousandBaseOffset)
                    if (firstDigit == "8") then
                        if (number < 7) then
                            character = nil
                        end
                    end
                elseif (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 3) then
                    character = nil
                end
            else
                -- |
                -- 1084
                -- 1000
                if (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 1) then
                    if (number > 0) then
                        character = nil
                    end
                elseif (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 2) then
                    if (number > 8) then
                        character = nil
                    end
                elseif (stringEnteredSoFar:len() - belowOneThousandBaseOffset == 3) then
                    local thirdDigit =
                        stringEnteredSoFar:sub(3 + belowOneThousandBaseOffset, 3 + belowOneThousandBaseOffset)
                    if (thirdDigit == "8") then
                        if (number > 4) then
                            character = nil
                        end
                    end
                end
            end
        end

        return character
    end
end

return BaroValidator
