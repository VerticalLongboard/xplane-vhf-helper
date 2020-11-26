local Utilities = require("shared_components.utilities")
local NotificationManager
do
    NotificationManager = {
        Constants = {
            NotificationStates = {
                Pending = "pending",
                Acknowledged = "acknowledged"
            }
        }
    }
    function NotificationManager:new()
        local newInstanceWithState = {
            notifications = {}
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end
    function NotificationManager:postOnce(notificationId)
        if (self.notifications[notificationId] ~= nil) then
            return
        end
        local newNotification = NotificationManager.Constants.NotificationStates.Pending
        self.notifications[notificationId] = newNotification
    end
    function NotificationManager:repost(notificationId)
        if (self.notifications[notificationId] == nil) then
            self:postOnce(notificationId)
            return
        end
        self.notifications[notificationId] = NotificationManager.Constants.NotificationStates.Pending
    end
    function NotificationManager:saveState(state)
        for nid, notificationState in pairs(self.notifications) do
            state[nid] = notificationState
        end
    end
    function NotificationManager:loadState(state)
        if (state == nil) then
            return
        end
        for nid, notificationState in pairs(state) do
            self.notifications[nid] = notificationState
        end
    end
    function NotificationManager:isPending(notificationId)
        if (self.notifications[notificationId] == nil) then
            return false
        end
        return self.notifications[notificationId] == NotificationManager.Constants.NotificationStates.Pending
    end
    function NotificationManager:acknowledge(notificationId)
        assert(notificationId)
        if (self.notifications[notificationId] == nil) then
            return
        end
        self.notifications[notificationId] = NotificationManager.Constants.NotificationStates.Acknowledged
    end
end
return NotificationManager
