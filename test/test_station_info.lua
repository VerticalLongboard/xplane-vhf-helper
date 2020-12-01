local allReadableNames = require("allReadableNames")
local allExpectedConvertedNames = require("allExpectedConvertedNames")
local StationInfo = require("vhf_helper.state.station_info")

TestComFrequencyPanel = {}

function TestComFrequencyPanel:testFixConvertedReadableNames()
    local allActualConvertedNames = {}
    luaUnit.assertEquals(#allReadableNames, #allExpectedConvertedNames)
    for _, name in ipairs(allReadableNames) do
        table.insert(allActualConvertedNames, StationInfo.getShortReadableStationName(name))
    end

    for i = 1, #allActualConvertedNames do
        luaUnit.assertEquals(allActualConvertedNames[i], allExpectedConvertedNames[i])
    end
end
