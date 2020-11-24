local Utilities = require("vhf_helper.shared_components.utilities")

local IniEditor
do
    IniEditor = {}

    function IniEditor:new()
        local newInstanceWithState = {
            lines = nil,
            filePath = nil,
            LineTypes = {
                Empty = "empty",
                Comment = "comment",
                Section = "section",
                KeyValue = "keyValue"
            },
            Matchers = {
                EmptyLine = "^%s*$",
                CommentLine = "^%s-[#;].-$",
                Comment = "^%s-[#;](.-)$",
                SectionLine = "^%s-%[.-%]%s-$",
                SectionName = "^%s-%[(.-)%]%s-$",
                KeyValueLine = "^%s*.-%s-=%s*.-$",
                KeyValue = "^%s*(.-)%s-=%s*(.-)$"
            }
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function IniEditor:loadFromFile(filePath)
        if (not Utilities.fileExists(filePath)) then
            return false
        end

        local content = Utilities.readAllContentFromFile(filePath)
        self.filePathBeforeLoadingIsComplete = filePath
        local result = self:loadFromString(content)
        if (not result) then
            return false
        end

        self.filePath = filePath
        return true
    end

    TRACK_ISSUE(
        "Tech Debt",
        "Not being able to load the file leaves IniEditor in a bad state. Reset (or force people to new() it)"
    )

    function IniEditor:getLastErrorOrNil()
        return self.lastError
    end

    function IniEditor:loadFromString(content)
        local lines = Utilities.splitStringBySeparator(content, "\n")

        self.unstructuredLines = {}
        self.structuredContent = {}

        local currentSection = nil
        local currentSectionName = nil
        for lineText in lines do
            local newLine = {}
            if (lineText:match(self.Matchers.EmptyLine)) then
                newLine.type = self.LineTypes.Empty
            elseif (lineText:match(self.Matchers.CommentLine)) then
                newLine.type = self.LineTypes.Comment
                newLine.comment = lineText:match(self.Matchers.Comment)
            elseif (lineText:match(self.Matchers.SectionLine)) then
                newLine.type = self.LineTypes.Section
                newLine.sectionName = lineText:match(self.Matchers.SectionName)
            elseif (lineText:match(self.Matchers.KeyValueLine)) then
                newLine.type = self.LineTypes.KeyValue
                local key, value = lineText:match(self.Matchers.KeyValue)
                newLine.key = key
                newLine.value = value
            else
                self.lastError =
                    ("IniEditor: INI file=%s has a syntax error in line='%s'"):format(
                    self.filePathBeforeLoadingIsComplete or "(loading from string)",
                    lineText
                )
                logMsg(self.lastError)
                return false
            end

            if (newLine.type == self.LineTypes.Section) then
                if (self.structuredContent[newLine.sectionName] ~= nil) then
                    self.lastError =
                        ("IniEditor: INI file=%s: Content text contains duplicate section=%s"):format(
                        self.filePathBeforeLoadingIsComplete,
                        newLine.sectionName
                    )
                    logMsg(self.lastError)
                    return false
                end

                local newSection = {}
                self.structuredContent[newLine.sectionName] = newSection
                currentSection = self.structuredContent[newLine.sectionName]
                currentSectionName = newLine.sectionName
            elseif (newLine.type == self.LineTypes.KeyValue) then
                if (currentSection == nil) then
                    self.lastError =
                        ("IniEditor: INI file=%s: Key=%s and Value=%s are outside any section."):format(
                        self.filePathBeforeLoadingIsComplete,
                        newLine.key,
                        newLine.value
                    )
                    logMsg(self.lastError)

                    return false
                end

                if (currentSection[newLine.key] ~= nil) then
                    self.lastError =
                        ("IniEditor: INI file=%s: Key=%s in Section=%s is duplicate"):format(
                        self.filePathBeforeLoadingIsComplete,
                        newLine.key,
                        currentSectionName
                    )

                    logMsg(self.lastError)
                    return false
                end

                local newKeyValue = newLine.value
                currentSection[newLine.key] = newKeyValue
            end

            newLine.removed = false
            newLine.text = lineText
            table.insert(self.unstructuredLines, newLine)
        end

        return true
    end

    function IniEditor:getFilePath()
        return self.filePath
    end

    function IniEditor:saveToFile(filePathOrNil)
        local actualPath = filePathOrNil or self.filePath
        if (actualPath == nil) then
            return false
        end

        local newFileContent = self:saveToString()
        Utilities.overwriteContentInFile(actualPath, newFileContent)

        return true
    end

    function IniEditor:saveToString()
        local newContent = ""
        for indexKey, line in pairs(self.unstructuredLines) do
            if (not line.removed) then
                newContent = newContent .. line.text .. "\n"
            end
        end

        return newContent
    end
end

function IniEditor:getAllKeyValueLinesByKeyMatcher(keyMatcher)
    local allLines = {}
    for _, line in pairs(self.unstructuredLines) do
        if (line.removed == false and line.type == self.LineTypes.KeyValue) then
            if (line.key:match(keyMatcher) ~= nil) then
                table.insert(allLines, line)
            end
        end
    end

    return allLines
end

function IniEditor:doesKeyValueExist(sectionName, key, value)
    if (self.structuredContent[sectionName] == nil) then
        return false
    end
    if (self.structuredContent[sectionName][key] == nil) then
        return false
    end
    if (self.structuredContent[sectionName][key] ~= value) then
        return false
    end
    return true
end

function IniEditor:removeAllKeyValueLinesByKeyMatcher(keyMatcher)
    for indexKey, line in pairs(self.unstructuredLines) do
        if (line.type == self.LineTypes.KeyValue) then
            if (line.key:match(keyMatcher) ~= nil) then
                line.removed = true
                self:_removeOneKeyFromStructuredContent(line.key)
            end
        end
    end
end

function IniEditor:_removeOneKeyFromStructuredContent(keyToRemove)
    for sectionName, section in pairs(self.structuredContent) do
        for key, _ in pairs(section) do
            if (key == keyToRemove) then
                section[key] = nil
                return
            end
        end
    end

    assert(nil)
end

function IniEditor:addKeyValueLine(sectionName, key, value)
    assert(sectionName)
    assert(key)
    assert(value)
    if (self.structuredContent[sectionName] == nil) then
        self.structuredContent[sectionName] = {}
        local newSectionLine = {
            type = self.LineTypes.Section,
            text = ("[%s]"):format(sectionName),
            sectionName = sectionName,
            removed = false
        }
        table.insert(self.unstructuredLines, newSectionLine)
    end

    local sectionLineIndex = nil
    for i = 1, #self.unstructuredLines do
        local line = self.unstructuredLines[i]
        if (line.type == self.LineTypes.Section and line.sectionName == sectionName) then
            sectionLineIndex = i
            break
        end
    end

    if (self.structuredContent[sectionName][key] ~= nil) then
        local isDuplicateReturn = false
        return isDuplicateReturn
    end

    local newKeyValueLine = {
        type = self.LineTypes.KeyValue,
        text = ("%s=%s"):format(key, value),
        key = key,
        value = value,
        removed = false
    }

    table.insert(self.unstructuredLines, sectionLineIndex + 1, newKeyValueLine)
    self.structuredContent[sectionName][key] = value

    return true
end

function IniEditor:getReadOnlyStructuredContent()
    return self.structuredContent
end

function IniEditor:getReadOnlyUnstructuredLines()
    return self.unstructuredLines
end

return IniEditor
