local LuaPlatform = require("lua_platform")

local Utilities = {}

Utilities.prefixAllLines = function(linesString, prefix)
    return prefix .. linesString:gsub("\n", "\n" .. prefix)
end

Utilities.fileExists = function(filePath)
    local file = LuaPlatform.IO.open(filePath, LuaPlatform.IO.Constants.Modes.Read)
    if file == nil then
        return false
    end

    file:close()
    return true
end

Utilities.readAllContentFromFile = function(filePath, modeOrNil)
    local file = LuaPlatform.IO.open(filePath, modeOrNil or LuaPlatform.IO.Constants.Modes.Read)
    assert(file)
    local content = file:read("*a")
    file:close()
    return content
end

Utilities.overwriteContentInFile = function(filePath, newContent, modeOrNil)
    local file = LuaPlatform.IO.open(filePath, modeOrNil or LuaPlatform.IO.Constants.Modes.Overwrite)
    assert(file)
    file:write(newContent)
    file:close()
end

Utilities.copyBinaryFile = function(fromPath, toPath)
    local fromContent =
        Utilities.readAllContentFromFile(
        fromPath,
        LuaPlatform.IO.Constants.Modes.Read .. LuaPlatform.IO.Constants.Modes.Binary
    )
    Utilities.overwriteContentInFile(
        toPath,
        fromContent,
        LuaPlatform.IO.Constants.Modes.Overwrite .. LuaPlatform.IO.Constants.Modes.Binary
    )
end

Utilities.copyFile = function(fromPath, toPath, readModeOrNil, writeModeOrNil)
    local fromContent = Utilities.readAllContentFromFile(fromPath, readModeOrNil)
    Utilities.overwriteContentInFile(toPath, fromContent, writeModeOrNil)
end

Utilities.splitStringBySeparator = function(str, separatorCharacter)
    if str:sub(-1) ~= separatorCharacter then
        str = str .. separatorCharacter
    end
    return str:gmatch("(.-)" .. separatorCharacter)
end

Utilities.newlineBreakStringAtWidth = function(str, width)
    local brokenString = ""
    local index = 1
    while true do
        local nextPart = str:sub(index, index + width - 1)
        if (nextPart:len() == 0) then
            break
        end
        brokenString = brokenString .. nextPart .. "\n"
        index = index + width
    end

    brokenString = brokenString:sub(1, -2)
    return brokenString
end

Utilities.urlEncode = function(str)
    str = str:gsub(" ", "%%20")
    str = str:gsub("\n", "%%0a")
    return str
end

Utilities.osExecuteEncode = function(str)
    str = str:gsub("&", "^&")
    str = str:gsub("<", "^<")
    str = str:gsub(">", "^>")
    return str
end

Utilities.trim = function(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

Utilities.openUrlInLocalDefaultBrowser = function(url)
    return Utilities.runLocally(Utilities.urlEncode(url))
end

Utilities.runLocally = function(callString)
    local call = 'start "" ' .. Utilities.osExecuteEncode(callString)
    local successErrorlevel = 0
    if (os.execute(call) ~= successErrorlevel) then
        return false
    end

    return true
end

Utilities.encodeHexToByte = function(str)
    return (str:gsub(
        "..",
        function(twoHexCharacters)
            return string.char(tonumber(twoHexCharacters, 16))
        end
    ))
end

Utilities.encodeByteToHex = function(str)
    return (str:gsub(
        ".",
        function(character)
            return string.format("%02X", string.byte(character))
        end
    ))
end

TRACK_ISSUE("Lua", "Lua does not offer a round function.", "Waste a minute and implement one.")
Utilities.roundFloatingPointToNearestInteger = function(v)
    return v + 0.5 - (v + 0.5) % 1
end

Utilities.DegToRad = 0.017453293
Utilities.FeetToM = 0.3048
Utilities.KnotsToKmh = 1.852
Utilities.EarthRadius = 6371
Utilities.FullCircleRadians = 6.28319
Utilities.NmToKm = 1.852
Utilities.KmToNm = 0.539957
Utilities.MeterToFeet = 3.28084

Utilities.computeDistanceOnEarth = function(latLon1, latLon2)
    latLon1[1] = latLon1[1] * Utilities.DegToRad
    latLon1[2] = latLon1[2] * Utilities.DegToRad
    latLon2[1] = latLon2[1] * Utilities.DegToRad
    latLon2[2] = latLon2[2] * Utilities.DegToRad
    local sinMeanLat = math.sin((latLon2[1] - latLon1[1]) * 0.5)
    local sinMeanLon = math.sin((latLon2[2] - latLon1[2]) * 0.5)
    local underSquareRoot =
        (sinMeanLat * sinMeanLat) + (math.cos(latLon1[1]) * math.cos(latLon2[1]) * (sinMeanLon * sinMeanLon))
    local centralAngle = 2.0 * math.asin(math.min(1.0, math.sqrt(underSquareRoot)))
    local earthRadius = 6371.0
    local d = centralAngle * earthRadius
    return d
end

Utilities.Math = {}
Utilities.Math.lerp = function(v1, v2, t)
    return v1 + (v2 - v1) * t
end

Utilities.getBlinkingColor = function(color, baseBrightness, blinkRate)
    return Utilities.getBlinkingColorBetweenTwo(0xFF000000, color, baseBrightness, blinkRate)
end

Utilities.getBlinkingColorBetweenTwo = function(color1, color2, baseBrightness, blinkRate)
    local brightness = (math.sin(LuaPlatform.Time.now() * blinkRate) + 1.0) * 0.5
    brightness = Utilities.Math.lerp(baseBrightness, 1.0, brightness)
    return Utilities.lerpColors(color1, color2, brightness)
end

TRACK_ISSUE(
    "Lua",
    "FlyWithLua is supposed to run Lua 5.1, which, in a clean development environment, does not support bit operations via bit.* functions.",
    "Disable in tests for now."
)
Utilities.lerpColors = function(color1, color2, t)
    if (IS_TEST ~= nil) then
        return 0xFF000000
    end

    local shiftByte = function(fourBytes, mask, shift)
        local byteOnly = bit.band(fourBytes, mask)
        byteOnly = bit.rshift(byteOnly, shift)
        return byteOnly
    end
    local getRed = function(color)
        return shiftByte(color, 0x000000FF, 0)
    end
    local getGreen = function(color)
        return shiftByte(color, 0x0000FF00, 8)
    end
    local getBlue = function(color)
        return shiftByte(color, 0x00FF0000, 16)
    end

    local red = Utilities.Math.lerp(getRed(color1), getRed(color2), t)
    local green = Utilities.Math.lerp(getGreen(color1), getGreen(color2), t)
    local blue = Utilities.Math.lerp(getBlue(color1), getBlue(color2), t)

    return Utilities.Color.getColorFromComponents(red, green, blue, 255)
end

Utilities.setByte = function(fourBytes, newByte, shift)
    if (IS_TEST ~= nil) then
        return 0xFF000000
    end

    local shifted = bit.lshift(newByte, shift)
    shifted = bit.bor(fourBytes, shifted)
    return shifted
end

Utilities.Color = {}

Utilities.Color.getColorFromComponents = function(r, g, b, a)
    local color = 0x00000000
    color = Utilities.Color.setRed(color, r)
    color = Utilities.Color.setGreen(color, g)
    color = Utilities.Color.setBlue(color, b)
    color = Utilities.Color.setAlpha(color, a)
    return color
end

Utilities.Color.setAlpha = function(color, newAlpha)
    return Utilities.setByte(color, newAlpha, 24)
end

Utilities.Color.setRed = function(color, newRed)
    return Utilities.setByte(color, newRed, 0)
end

Utilities.Color.setGreen = function(color, newGreen)
    return Utilities.setByte(color, newGreen, 8)
end

Utilities.Color.setBlue = function(color, newBlue)
    return Utilities.setByte(color, newBlue, 16)
end

return Utilities
