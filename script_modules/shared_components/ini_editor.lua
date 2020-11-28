local Utilities = require("shared_components.utilities")

local IniEditor
do
    IniEditor = {
        LoadModes = {
            Normal = "Normal",
            IgnoreDuplicateKeys = "IgnoreDuplicateKeys"
        },
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

    function IniEditor:new()
        local newInstanceWithState = {
            lines = nil,
            filePath = nil
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function IniEditor:_reset()
        self.filePath = nil
        self.loadMode = nil
        self.lastError = nil
        self.unstructuredLines = {}
        self.structuredContent = {}
    end

    function IniEditor:loadFromFile(filePath, loadMode)
        if (loadMode == nil) then
            loadMode = self.LoadModes.Normal
        end

        if (not Utilities.fileExists(filePath)) then
            return false
        end

        self:_reset()

        local content = Utilities.readAllContentFromFile(filePath)
        self.filePathBeforeLoadingIsComplete = filePath
        local result = self:loadFromString(content, loadMode)
        if (not result) then
            self:_reset()
            return false
        end

        self.filePath = filePath
        return true
    end

    function IniEditor:getLastErrorOrNil()
        return self.lastError
    end

    function IniEditor:loadFromString(content, loadMode)
        if (loadMode == nil) then
            loadMode = self.LoadModes.Normal
        end

        local lines = Utilities.splitStringBySeparator(content, "\n")

        self.unstructuredLines = {}
        self.structuredContent = {}

        local currentSection = nil
        local currentSectionName = nil
        local currentLineNumber = 1
        local ignoreNewLine = nil
        for lineText in lines do
            local newLine = {}
            ignoreNewLine = false

            if (lineText:match(IniEditor.Matchers.EmptyLine)) then
                newLine.type = IniEditor.LineTypes.Empty
            elseif (lineText:match(IniEditor.Matchers.CommentLine)) then
                newLine.type = IniEditor.LineTypes.Comment
                newLine.comment = lineText:match(IniEditor.Matchers.Comment)
            elseif (lineText:match(IniEditor.Matchers.SectionLine)) then
                newLine.type = IniEditor.LineTypes.Section
                newLine.sectionName = lineText:match(IniEditor.Matchers.SectionName)
            elseif (lineText:match(IniEditor.Matchers.KeyValueLine)) then
                newLine.type = IniEditor.LineTypes.KeyValue
                local key, value = lineText:match(IniEditor.Matchers.KeyValue)
                newLine.key = key
                newLine.value = value
            else
                self.lastError =
                    ("IniEditor: INI file=%s:%d has a syntax error in line='%s'"):format(
                    self.filePathBeforeLoadingIsComplete or "(loading from string)",
                    currentLineNumber,
                    lineText
                )
                logMsg(self.lastError)
                return false
            end

            if (newLine.type == IniEditor.LineTypes.Section) then
                if (self.structuredContent[newLine.sectionName] ~= nil) then
                    self.lastError =
                        ("IniEditor: INI file=%s:%d: Content text contains duplicate section=%s"):format(
                        self.filePathBeforeLoadingIsComplete,
                        currentLineNumber,
                        newLine.sectionName
                    )
                    logMsg(self.lastError)
                    return false
                end

                local newSection = {}
                self.structuredContent[newLine.sectionName] = newSection
                currentSection = self.structuredContent[newLine.sectionName]
                currentSectionName = newLine.sectionName
            elseif (newLine.type == IniEditor.LineTypes.KeyValue) then
                if (currentSection == nil) then
                    self.lastError =
                        ("IniEditor: INI file=%s:%d: Key=%s and Value=%s are outside any section."):format(
                        self.filePathBeforeLoadingIsComplete,
                        currentLineNumber,
                        newLine.key,
                        newLine.value
                    )
                    logMsg(self.lastError)

                    return false
                end

                if (currentSection[newLine.key] ~= nil) then
                    if (loadMode == self.LoadModes.Normal) then
                        self.lastError =
                            ("IniEditor: INI file=%s:%d: Key=%s in Section=%s is duplicate"):format(
                            self.filePathBeforeLoadingIsComplete,
                            currentLineNumber,
                            newLine.key,
                            currentSectionName
                        )

                        logMsg(self.lastError)
                        return false
                    else
                        ignoreNewLine = true
                    end
                end

                local newKeyValue = newLine.value
                currentSection[newLine.key] = newKeyValue
            end

            if (not ignoreNewLine) then
                newLine.removed = false
                newLine.text = lineText
                table.insert(self.unstructuredLines, newLine)
            end

            currentLineNumber = currentLineNumber + 1
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
    function IniEditor:getAllKeyValueLinesByKeyMatcher(keyMatcher)
        local allLines = {}
        for _, line in pairs(self.unstructuredLines) do
            if (line.removed == false and line.type == IniEditor.LineTypes.KeyValue) then
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
            if (line.type == IniEditor.LineTypes.KeyValue) then
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
                type = IniEditor.LineTypes.Section,
                text = ("[%s]"):format(sectionName),
                sectionName = sectionName,
                removed = false
            }
            table.insert(self.unstructuredLines, newSectionLine)
        end

        local sectionLineIndex = nil
        for i = 1, #self.unstructuredLines do
            local line = self.unstructuredLines[i]
            if (line.type == IniEditor.LineTypes.Section and line.sectionName == sectionName) then
                sectionLineIndex = i
                break
            end
        end

        if (self.structuredContent[sectionName][key] ~= nil) then
            local isDuplicateReturn = false
            return isDuplicateReturn
        end

        local newKeyValueLine = {
            type = IniEditor.LineTypes.KeyValue,
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
end

return IniEditor
