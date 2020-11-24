local Globals = require("vhf_helper.globals")
local Utilities = require("vhf_helper.shared_components.utilities")
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
        if (not Utilities.fileExists(self.Path)) then
            return
        end

        self.Content = LuaIniParser.load(self.Path)
    end

    function Configuration:save()
        if (not self.isDirty) then
            return
        end
        LuaIniParser.save(self.Path, self.Content)
        self.isDirty = false
    end

    function Configuration:setValue(section, key, value)
        if (self.Content[section] == nil) then
            self.Content[section] = {}
        end
        if (type(value) == "string") then
            value = Globals.trim(value)
        end

        self.Content[section][key] = value

        self:_markDirty()
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

    function Configuration:_markDirty()
        self.isDirty = true
    end
end

Configuration.Constants = {
    BooleanTrue = "yes",
    BooleanFalse = "no"
}

Configuration.getBooleanFromValue = function(stringValue)
    if (stringValue == Configuration.Constants.BooleanTrue) then
        return true
    else
        return false
    end
end

Configuration.getValueFromBoolean = function(boolean)
    if (boolean) then
        return Configuration.Constants.BooleanTrue
    else
        return Configuration.Constants.BooleanFalse
    end
end

return Configuration
