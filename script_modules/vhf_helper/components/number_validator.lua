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

    function NumberValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
        assert(nil)
    end
end

return NumberValidator
