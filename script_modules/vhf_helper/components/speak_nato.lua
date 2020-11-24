local SpeakNato
do
    SpeakNato = {}

    function SpeakNato:new()
        local newInstanceWithState = {}

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end
end

SpeakNato.speakFrequency = function(string)
    SpeakNato._speak(SpeakNato._getNatoStringForFrequency(string))
end

SpeakNato.speakTransponderCode = function(string)
    SpeakNato._speak(SpeakNato._getNatoStringForTransponderCode(string))
end

SpeakNato._getNatoStringForTransponderCode = function(string)
    string = string:gsub("000$", "towsent ")
    return SpeakNato._getNatoStringForNumbers(string)
end

SpeakNato._getNatoStringForFrequency = function(string)
    string = string:gsub("0-$", "")
    return SpeakNato._getNatoStringForNumbers(string)
end

SpeakNato._getNatoStringForNumbers = function(string)
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

TRACK_ISSUE("Tech Debt", "This function is not yet required. It's waste, implemented too soon.")
SpeakNato._getNatoStringForLetters = function(string)
    string = string:gsub("A", " alfah ")
    string = string:gsub("B", " brahvoh ")
    string = string:gsub("C", " charlie ")
    string = string:gsub("D", " delta ")
    string = string:gsub("E", " echo ")
    string = string:gsub("F", " foxtrot ")
    string = string:gsub("G", " golf ")
    string = string:gsub("H", " hotell ")
    string = string:gsub("I", " inndeeah ")
    string = string:gsub("J", " juliet ")
    string = string:gsub("K", " kilo ")
    string = string:gsub("L", " lima ")
    string = string:gsub("M", " mike ")
    string = string:gsub("N", " novemmber ")
    string = string:gsub("O", " oscar ")
    string = string:gsub("P", " papa ")
    string = string:gsub("Q", " kebec ")
    string = string:gsub("R", " romeo ")
    string = string:gsub("S", " sierrahh ")
    string = string:gsub("T", " tango ")
    string = string:gsub("U", " uniform ")
    string = string:gsub("V", " victor ")
    string = string:gsub("W", " whizzkee ")
    string = string:gsub("X", " x ray ")
    string = string:gsub("Y", " yankee ")
    string = string:gsub("Z", " zulu ")
    return string
end

SpeakNato._speak = function(string)
    XPLMSpeakString(string)
end

return SpeakNato
