local allReadableNames = require("allReadableNames")
local allExpectedConvertedNames = require("allExpectedConvertedNames")
local ComFrequencySubPanel = require("vhf_helper.components.com_frequency_sub_panel")

TestComFrequencyPanel = {}

function TestComFrequencyPanel:testFixConvertedReadableNames()
    local allActualConvertedNames = {}
    luaUnit.assertEquals(#allReadableNames, #allExpectedConvertedNames)
    for _, name in ipairs(allReadableNames) do
        table.insert(allActualConvertedNames, ComFrequencySubPanel:_getShortReadableStationName(name))
    end

    for i = 1, #allActualConvertedNames do
        luaUnit.assertEquals(allActualConvertedNames[i], allExpectedConvertedNames[i])
    end
end
