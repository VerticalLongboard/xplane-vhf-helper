LuaPlatform = require("lua_platform")

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

Utilities.readAllContentFromFile = function(filePath)
    local file = LuaPlatform.IO.open(filePath, LuaPlatform.IO.Constants.Modes.Read)
    assert(file)
    local content = file:read("*a")
    file:close()
    return content
end

Utilities.overwriteContentInFile = function(filePath, newContent)
    local file = LuaPlatform.IO.open(filePath, LuaPlatform.IO.Constants.Modes.Overwrite)
    assert(file)
    file:write(newContent)
    file:close()
end

Utilities.copyFile = function(fromPath, toPath)
    local fromContent = Utilities.readAllContentFromFile(fromPath)
    Utilities.overwriteContentInFile(toPath, fromContent)
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
    local call = 'start "" ' .. Utilities.osExecuteEncode(Utilities.urlEncode(url))
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

return Utilities
