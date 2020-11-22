local IniEditor
do
    IniEditor = {}

    function IniEditor:new()
        local newInstanceWithState = {
            content = nil,
            filePath = nil
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function IniEditor:load(filePath)
    end

    function IniEditor:save(filePathOrNil)
    end
end
return IniEditor
