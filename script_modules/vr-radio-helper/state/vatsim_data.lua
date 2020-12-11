Globals = require("vr-radio-helper.globals")

local function retrieveInfoForAlternateFrequency(fullFrequencyString)
    local lastDigit = fullFrequencyString:sub(7, 7)
    if (lastDigit == "5") then
        fullFrequencyString = Globals.replaceCharacter(fullFrequencyString, 7, "0")
    elseif (lastDigit == "0") then
        fullFrequencyString = Globals.replaceCharacter(fullFrequencyString, 7, "5")
    end
    atcInfos = VatsimbriefHelperPublicInterface.getAtcStationsForFrequencyClosestFirst(fullFrequencyString)
    if (atcInfos == nil or #atcInfos == 0) then
        return nil
    end

    return atcInfos[1]
end

local function isVatsimbriefHelperAvailable()
    return VatsimbriefHelperPublicInterface ~= nil and VatsimbriefHelperPublicInterface.getInterfaceVersion() == 2
end

local function retrieveInfoForFrequency(fullFrequencyString)
    if (not isVatsimbriefHelperAvailable()) then
        return nil
    end

    local atcInfos = VatsimbriefHelperPublicInterface.getAtcStationsForFrequencyClosestFirst(fullFrequencyString)
    if (atcInfos == nil or #atcInfos == 0) then
        return retrieveInfoForAlternateFrequency(fullFrequencyString)
    end
    return atcInfos[1]
end

local function getShortReadableStationName(longReadableName)
    if (longReadableName == nil) then
        return nil
    end
    local firstW = longReadableName:find("%w")
    if (firstW == nil) then
        return ""
    end

    local i = firstW
    local lastNameCharacter = i
    while i <= #longReadableName do
        local char = longReadableName:sub(i, i)
        local matchesW = char:match("%w")
        local matchesWhitespace = char:match("%s")
        if (matchesW) then
            lastNameCharacter = i
        end
        if (matchesW or matchesWhitespace) then
            i = i + 1
        else
            break
        end
    end

    return longReadableName:sub(firstW, lastNameCharacter)
end

local function getAllVatsimClientsWithOwnCallsignAndTimestamp()
    if (not isVatsimbriefHelperAvailable()) then
        return nil, nil, 0
    end

    local clients, timestamp = VatsimbriefHelperPublicInterface.getAllVatsimClientsClosestFirstWithTimestamp()
    local ownCallsign = VatsimbriefHelperPublicInterface.getOwnCallSign()

    return clients, ownCallsign, timestamp
end

local M = {}
M.bootstrap = function()
    M.mapFrequencyToAtcInfo = {}
    M.updateInfoForFrequency = function(fullFrequencyString)
        M.mapFrequencyToAtcInfo[fullFrequencyString] = retrieveInfoForFrequency(fullFrequencyString)
        local cachedInfo = M.mapFrequencyToAtcInfo[fullFrequencyString]
        if (cachedInfo ~= nil) then
            cachedInfo.shortReadableName = getShortReadableStationName(cachedInfo.description)
        end

        return cachedInfo
    end
    M.getInfoForFrequency = function(fullFrequencyString)
        return M.mapFrequencyToAtcInfo[fullFrequencyString]
    end
    M.getShortReadableStationName = getShortReadableStationName
    M.isVatsimbriefHelperAvailable = isVatsimbriefHelperAvailable
    M.getAllVatsimClientsWithOwnCallsignAndTimestamp = getAllVatsimClientsWithOwnCallsignAndTimestamp
end
return M
