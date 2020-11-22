TestSpeakNato = {}

SpeakNato = require("vhf_helper.components.speak_nato")

function TestSpeakNato:setUp()
    self.speakNato = SpeakNato:new()
end

TRACK_ISSUE("SpeakNato", "Tests don't include any actual call to the platform speak function.")
function TestSpeakNato:testFrequencySpeakingWorks()
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("122.8"), "won too too decimal ate ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("109.30"), "won zeero niner decimal tree ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("133.900"), "won tree tree decimal niner ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("120.640"), "won too zeero decimal siccs fore ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("135.687"), "won tree five decimal siccs ate seven ")
end

function TestSpeakNato:testTransponderCodeSpeakingWorks()
    luaUnit.assertEquals(SpeakNato:_getNatoStringForTransponderCode("1000"), "won towsent ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForTransponderCode("3506"), "tree five zeero siccs ")
end
