TestSpeakNato = {}

SpeakNato = require("vhf_helper.components.speak_nato")

function TestSpeakNato:setUp()
    self.speakNato = SpeakNato:new()
end

function TestSpeakNato:testFrequencySpeakingWorks()
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("133.900"), "won tree tree decimal niner ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("109.300"), "won zeero niner decimal tree ")
    luaUnit.assertEquals(SpeakNato:_getNatoStringForFrequency("120.640"), "won too zeero decimal siccs fore ")
end

function TestSpeakNato:testSingleNumberSpeakingWorks()
    luaUnit.assertEquals(SpeakNato:_getNatoStringForSingleNumber("1000"), "won towsend ")
end
