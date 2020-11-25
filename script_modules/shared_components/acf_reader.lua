local Utilities = require("shared_components.utilities")

local AcfReader
do
    AcfReader = {}

    function AcfReader:new()
        local newInstanceWithState = {
            filePath = nil,
            LineTypes = {
                Unknown = "Unknown",
                PropertyValue = "PropertyValue"
            },
            Matchers = {
                PropertyValueLine = "^%s*P%s+[^%s]+%s+.+$",
                PropertyValue = "^%s*P%s+([^%s]+)%s+(.+)$"
            }
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function AcfReader:loadFromFile(filePath)
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

    function AcfReader:loadFromString(content)
        local lines = Utilities.splitStringBySeparator(content, "\n")

        self.unstructuredLines = {}

        local currentLineNumber = 1
        for lineText in lines do
            local newLine = {}
            if (lineText:match(self.Matchers.PropertyValueLine)) then
                newLine.type = self.LineTypes.Property
                local property, value = lineText:match(self.Matchers.PropertyValue)
                newLine.property = property
                newLine.value = value
            else
                newLine.type = self.LineTypes.Unknown
            end

            newLine.text = lineText
            table.insert(self.unstructuredLines, newLine)
            currentLineNumber = currentLineNumber + 1
        end

        return true
    end

    function AcfReader:getPropertyValue(propertyName)
        if (self.unstructuredLines == nil) then
            return nil
        end

        for _, line in pairs(self.unstructuredLines) do
            if (line.property == propertyName) then
                return line.value
            end
        end

        return nil
    end

    function AcfReader:getFilePath()
        return self.filePath
    end
end

return AcfReader
