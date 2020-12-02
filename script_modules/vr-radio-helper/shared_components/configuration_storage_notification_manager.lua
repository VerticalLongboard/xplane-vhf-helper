local NotificationManager = require("vr-radio-helper.shared_components.notification_manager")
local Globals = require("vr-radio-helper.globals")
local Configuration = require("vr-radio-helper.shared_components.configuration")
local Config = require("vr-radio-helper.state.config")

local ConfigurationStorageNotificationManager
do
    ConfigurationStorageNotificationManager = NotificationManager:new()

    Globals.OVERRIDE(ConfigurationStorageNotificationManager.new)
    function ConfigurationStorageNotificationManager:new(newConfiguration)
        assert(newConfiguration)
        local newInstanceWithState = NotificationManager:new()
        newInstanceWithState.configuration = newConfiguration

        setmetatable(newInstanceWithState, self)
        self.__index = self

        NotificationManager.loadState(newInstanceWithState, newConfiguration.Content.Notifications)
        return newInstanceWithState
    end

    Globals.OVERRIDE(ConfigurationStorageNotificationManager.postOnce)
    function ConfigurationStorageNotificationManager:postOnce(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.postOnce, notificationId)
    end

    Globals.OVERRIDE(ConfigurationStorageNotificationManager.repost)
    function ConfigurationStorageNotificationManager:repost(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.repost, notificationId)
    end

    Globals.OVERRIDE(ConfigurationStorageNotificationManager.acknowledge)
    function ConfigurationStorageNotificationManager:acknowledge(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.acknowledge, notificationId)
    end

    Globals._NEWFUNC(ConfigurationStorageNotificationManager._saveToConfigIfStateChanges)
    function ConfigurationStorageNotificationManager:_saveToConfigIfStateChanges(managerFunction, notificationId)
        local oldPending = self:isPending(notificationId)
        managerFunction(self, notificationId)
        if (self:isPending(notificationId) == oldPending) then
            return
        end
        if (self.configuration.Content.Notifications == nil) then
            self.configuration.Content["Notifications"] = {}
        end

        self:saveState(self.configuration.Content.Notifications)
        self.configuration:markDirty()
    end
end

return ConfigurationStorageNotificationManager
