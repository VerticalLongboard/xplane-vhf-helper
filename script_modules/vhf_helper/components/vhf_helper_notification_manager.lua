local NotificationManager = require("shared_components.notification_manager")
local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")

local VhfHelperNotificationManager
do
    VhfHelperNotificationManager = NotificationManager:new()

    Globals.OVERRIDE(VhfHelperNotificationManager.postOnce)
    function VhfHelperNotificationManager:postOnce(notificationId)
        self:_saveToConfigIfStateChanged(NotificationManager.postOnce, notificationId)
    end

    Globals.OVERRIDE(VhfHelperNotificationManager.repost)
    function VhfHelperNotificationManager:repost(notificationId)
        self:_saveToConfigIfStateChanged(NotificationManager.repost, notificationId)
    end

    Globals.OVERRIDE(VhfHelperNotificationManager.acknowledge)
    function VhfHelperNotificationManager:acknowledge(notificationId)
        self:_saveToConfigIfStateChanged(NotificationManager.acknowledge, notificationId)
    end

    Globals._NEWFUNC(VhfHelperNotificationManager._saveToConfig)
    function VhfHelperNotificationManager:_saveToConfigIfStateChanged(managerFunction, notificationId)
        local oldPending = self:isPending(notificationId)

        logMsg("-----------------" .. notificationId)
        managerFunction(self, notificationId)

        if (self:isPending(notificationId) == oldPending) then
            return
        end

        if (Config.Config.Content.Notifications == nil) then
            Config.Config.Content["Notifications"] = {}
        end

        self:saveState(Config.Config.Content.Notifications)
        logMsg(
            "HM:" ..
                notificationId .. " value in state=" .. tostring(Config.Config.Content.Notifications[notificationId])
        )
        Config.Config:markDirty()
    end
end

return VhfHelperNotificationManager
