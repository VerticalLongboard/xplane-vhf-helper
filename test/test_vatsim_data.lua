local allReadableNames = require("allReadableNames")
local allExpectedConvertedNames = require("allExpectedConvertedNames")
local VatsimData = require("vr-radio-helper.state.vatsim_data")

TestComFrequencyPanel = {}

function TestComFrequencyPanel:testFixConvertedReadableNames()
    local allActualConvertedNames = {}
    luaUnit.assertEquals(#allReadableNames, #allExpectedConvertedNames)
    for _, name in ipairs(allReadableNames) do
        table.insert(allActualConvertedNames, VatsimData.getShortReadableStationName(name))
    end

    for i = 1, #allActualConvertedNames do
        luaUnit.assertEquals(allActualConvertedNames[i], allExpectedConvertedNames[i])
    end
end
