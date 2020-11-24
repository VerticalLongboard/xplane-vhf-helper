local Utilities = {}

Utilities.prefixAllLines = function(linesString, prefix)
    return prefix .. linesString:gsub("\n", "\n" .. prefix)
end

Utilities.fileExists = function(filePath)
    local file = io.open(filePath, "r")
    if file == nil then
        return false
    end

    io.close(file)
    return true
end

Utilities.readAllContentFromFile = function(filePath)
    local file = io.open(filePath, "r")
    assert(file)
    local content = file:read("*a")
    file:close()
    return content
end

Utilities.overwriteContentInFile = function(filePath, newContent)
    local file = io.open(filePath, "w")
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

return Utilities
