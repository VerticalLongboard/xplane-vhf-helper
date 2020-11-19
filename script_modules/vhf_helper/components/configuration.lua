local Globals = require("vhf_helper.globals")
local LuaIniParser = require("LIP")

local Configuration
do
    Configuration = {}

    function Configuration:new(iniFilePath)
        local newInstanceWithState = {Path = iniFilePath, Content = {}}
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function Configuration:load()
        if (not Globals.fileExists(self.Path)) then
            return
        end

        self.Content = LuaIniParser.load(self.Path)
    end

    function Configuration:save()
        LuaIniParser.save(self.Path, self.Content)
    end

    function Configuration:setValue(section, key, value)
        if (self.Content[section] == nil) then
            self.Content[section] = {}
        end
        if (type(value) == "string") then
            value = Globals.trim(value)
        end

        self.Content[section][key] = value
    end

    function Configuration:getValue(section, key, defaultValue)
        if (self.Content[section] == nil) then
            self.Content[section] = {}
        end
        if (self.Content[section][key]) == nil then
            self.Content[section][key] = defaultValue
        end

        return self.Content[section][key]
    end
end

return Configuration
