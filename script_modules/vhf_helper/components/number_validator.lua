local NumberValidator
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

    function NumberValidator:getValidNumberCharacterOrNil(stringEnteredSoFar, number)
        local numberAsString = tostring(number)
        local afterEnteringNumber = stringEnteredSoFar .. numberAsString
        local autocompleted = self:autocomplete(afterEnteringNumber)
        if (self:validate(autocompleted) == nil) then
            return nil
        end

        return numberAsString
    end
end

return NumberValidator
