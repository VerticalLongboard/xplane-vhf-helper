local Utilities = require("shared_components.utilities")
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

        TRACK_ISSUE(
            "Lua",
            MULTILINE_TEXT(
                "At the current commit (where this issue got added), assigning nil to self.Content does NOT assign NIL.",
                "Instead, the assignment silently fails and sets self.Content reference to it's value before.",
                "Also, setting it to something and then nil again yields the old reference value.",
                "Only assigning something non-nil to self.Content before changes self.Content. A bug?!"
            )
        )
        -- local bla = LuaIniParser.load(self.Path)
        -- -- logMsg("BLA=" .. tostring(bla))
        -- -- self.Content = nil
        -- -- self.Content = bla
        -- -- self.Content = nil
        -- -- self.Content = nil
        -- TRACK_ISSUE(
        --     "Lua",
        --     MULTILINE_TEXT(
        --         "At the current commit (where this issue got added), assigning nil to self.Content does NOT assign NIL.",
        --         "Instead, the assignment silently fails and sets self.Content reference to it's value before.",
        --         "Also, setting it to something and then nil again yields the old reference value.",
        --         "Only assigning something non-nil to self.Content before changes self.Content. A bug?!"
        --     )
        -- )
        -- self.Content = {} -- That's the one.
        -- -- self.Content = nil -- Does NOT work. Doesn't assign nil, but instead an old value -- Un-Comment this line to trigger the bug.

        -- logMsg("BLA2=" .. tostring(self.Content))
        -- logMsg(
        --     "loaded isStub=" ..
        --         tostring(LuaIniParser.isStub) ..
        --             " content=" .. require("luaunit").prettystr(self.Content) .. " from path=" .. tostring(self.Path)
        -- )

        -- self.Content = {}
        self.Content = LuaIniParser.load(self.Path)
    end

    function Configuration:save()
        if (not self.isDirty) then
            return
        end
        -- LuaIniParser.save(self.Path, self.Content)
        self.isDirty = false
    end

    function Configuration:setValue(section, key, value)
        if (self.Content[section] == nil) then
            self.Content[section] = {}
        end
        if (type(value) == "string") then
            value = Utilities.trim(value)
        end

        self.Content[section][key] = value

        self:markDirty()
    end

    function Configuration:getValue(section, key, defaultValue)
        if (self.Content[section] == nil) then
            self.Content[section] = {}
            self:markDirty()
        end
        if (self.Content[section][key]) == nil then
            self.Content[section][key] = defaultValue
            self:markDirty()
        end

        return self.Content[section][key]
    end

    function Configuration:markDirty()
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
