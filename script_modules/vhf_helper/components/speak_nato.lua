local SpeakNato
do
    SpeakNato = {}

    function SpeakNato:new()
        local newInstanceWithState = {}

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function SpeakNato:_speak(string)
        XPLMSpeakString(string)
    end

    function SpeakNato:speakSingleNumber(string)
        self:_speak(self:_getNatoStringForSingleNumber(string))
    end

    function SpeakNato:speakFrequency(string)
        self:_speak(self:_getNatoStringForFrequency(string))
    end

    function SpeakNato:_getNatoStringForSingleNumber(string)
        string = string:gsub("000$", "towsend ")
        return self:_getNatoStringForNumbers(string)
    end

    function SpeakNato:_getNatoStringForFrequency(string)
        string = string:gsub("0-$", "")
        return self:_getNatoStringForNumbers(string)
    end

    function SpeakNato:_getNatoStringForNumbers(string)
        string = string:gsub("0", "zeero ")
        string = string:gsub("1", "won ")
        string = string:gsub("2", "too ")
        string = string:gsub("3", "tree ")
        string = string:gsub("4", "fore ")
        string = string:gsub("5", "five ")
        string = string:gsub("6", "siccs ")
        string = string:gsub("7", "seven ")
        string = string:gsub("8", "ate ")
        string = string:gsub("9", "niner ")
        string = string:gsub("%.", "decimal ")

        return string
    end
end

return SpeakNato
