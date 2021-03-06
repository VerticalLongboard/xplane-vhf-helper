TestSpeakNato = {}

SpeakNato = require("vr-radio-helper.components.speak_nato")

function TestSpeakNato:setUp()
    self.speakNato = SpeakNato:new()
end

function TestSpeakNato:testFrequencyStringConversionWorks()
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("122.8"), "won too too decimal ate ")
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("109.30"), "won zeero niner decimal tree ")
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("133.900"), "won tree tree decimal niner ")
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("120.640"), "won too zeero decimal siccs fore ")
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("135.687"), "won tree five decimal siccs ate seven ")
end

function TestSpeakNato:testTransponderCodeStringConversionWorks()
    luaUnit.assertEquals(SpeakNato._getNatoStringForFourDigitNumber("1000"), "won towsent ")
    luaUnit.assertEquals(SpeakNato._getNatoStringForFourDigitNumber("3506"), "tree five zeero siccs ")
end

function TestSpeakNato:testSpeakingSpeaks()
    self.speakNato.speakFrequency("132.607")
    luaUnit.assertEquals(flyWithLuaStub:getLastSpeakString(), "won tree too decimal siccs zeero seven ")
    self.speakNato.speakTransponderCode("6000")
    luaUnit.assertEquals(flyWithLuaStub:getLastSpeakString(), "siccs towsent ")
end

function TestSpeakNato:testFrequenciesWithZeroAfterDecimalSpeakAtLeastOneZero()
    luaUnit.assertEquals(SpeakNato._getNatoStringForFrequency("118.0"), "won won ate decimal zeero ")
end
