local NotificationManager = require("shared_components.notification_manager")
local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")

local VhfHelperNotificationManager
do
    VhfHelperNotificationManager = NotificationManager:new()

    Globals.OVERRIDE(VhfHelperNotificationManager.postOnce)
    function VhfHelperNotificationManager:postOnce(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.postOnce, notificationId)
    end

    Globals.OVERRIDE(VhfHelperNotificationManager.repost)
    function VhfHelperNotificationManager:repost(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.repost, notificationId)
    end

    Globals.OVERRIDE(VhfHelperNotificationManager.acknowledge)
    function VhfHelperNotificationManager:acknowledge(notificationId)
        self:_saveToConfigIfStateChanges(NotificationManager.acknowledge, notificationId)
    end

    Globals._NEWFUNC(VhfHelperNotificationManager._saveToConfigIfStateChanges)
    function VhfHelperNotificationManager:_saveToConfigIfStateChanges(managerFunction, notificationId)
        local oldPending = self:isPending(notificationId)
        managerFunction(self, notificationId)
        if (self:isPending(notificationId) == oldPending) then
            return
        end
        if (Config.Config.Content.Notifications == nil) then
            Config.Config.Content["Notifications"] = {}
        end

        self:saveState(Config.Config.Content.Notifications)
        Config.Config:markDirty()
    end
end

return VhfHelperNotificationManager
