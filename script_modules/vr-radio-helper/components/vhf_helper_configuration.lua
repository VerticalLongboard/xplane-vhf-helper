local Configuration = require("vr-radio-helper.shared_components.configuration")
local Globals = require("vr-radio-helper.globals")

local VhfHelperConfiguration
do
    VhfHelperConfiguration = Configuration:new()

    Globals.OVERRIDE(VhfHelperConfiguration.new)
    function VhfHelperConfiguration:new(iniFilePath)
        local newInstanceWithState = {Path = iniFilePath, Content = {}}
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    Globals._NEWFUNC(VhfHelperConfiguration.getInitialWindowVisibility)
    function VhfHelperConfiguration:getInitialWindowVisibility()
        return Configuration.getBooleanFromValue(
            self:getValue("Windows", "MainWindowInitiallyVisible", Configuration.Constants.BooleanFalse)
        )
    end

    Globals._NEWFUNC(VhfHelperConfiguration.setInitialWindowVisibility)
    function VhfHelperConfiguration:setInitialWindowVisibility(booleanValue)
        self:setValue("Windows", "MainWindowInitiallyVisible", Configuration.getValueFromBoolean(booleanValue))
    end

    Globals._NEWFUNC(VhfHelperConfiguration.getSpeakNumbersLocally)
    function VhfHelperConfiguration:getSpeakNumbersLocally()
        return Configuration.getBooleanFromValue(
            self:getValue("Audio", "SpeakNumbersLocally", Configuration.Constants.BooleanTrue)
        )
    end

    Globals._NEWFUNC(VhfHelperConfiguration.setSpeakNumbersLocally)
    function VhfHelperConfiguration:setSpeakNumbersLocally(booleanValue)
        self:setValue("Audio", "SpeakNumbersLocally", Configuration.getValueFromBoolean(booleanValue))
    end

    Globals._NEWFUNC(VhfHelperConfiguration.getSpeakRemoteNumbers)
    function VhfHelperConfiguration:getSpeakRemoteNumbers()
        return Configuration.getBooleanFromValue(
            self:getValue("Audio", "SpeakRemoteNumbers", Configuration.Constants.BooleanTrue)
        )
    end

    Globals._NEWFUNC(VhfHelperConfiguration.setSpeakRemoteNumbers)
    function VhfHelperConfiguration:setSpeakRemoteNumbers(booleanValue)
        self:setValue("Audio", "SpeakRemoteNumbers", Configuration.getValueFromBoolean(booleanValue))
    end

    Globals.OVERRIDE(VhfHelperConfiguration.save)
    function VhfHelperConfiguration:save()
        if (self.isDirty) then
            Globals.printLogMessage("Saving configuration due to recent change.")
        end
        Configuration.save(self)
    end
end
return VhfHelperConfiguration
