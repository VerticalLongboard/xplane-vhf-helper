local Utilities = require("shared_components.utilities")

local NotificationManager
do
    NotificationManager = {}

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

        local newNotification = {
            isPending = true
        }

        self.notifications[notificationId] = newNotification
    end

    function NotificationManager:repost(notificationId)
        if (self.notifications[notificationId] == nil) then
            self:postOnce(notificationId)
            return
        end

        self.notifications[notificationId].isPending = true
    end

    function NotificationManager:saveState(state)
        for nid, notification in pairs(self.notifications) do
            state[nid] = notification.isPending
        end
    end

    function NotificationManager:loadState(state)
        if (state == nil) then
            return
        end
        for nid, pending in pairs(state) do
            self.notifications[nid] = {
                isPending = pending
            }
        end
    end

    function NotificationManager:isPending(notificationId)
        if (self.notifications[notificationId] == nil) then
            return false
        end
        return self.notifications[notificationId].isPending
    end

    function NotificationManager:acknowledge(notificationId)
        if (self.notifications[notificationId] == nil) then
            return
        end
        self.notifications[notificationId].isPending = false
    end
end

return NotificationManager
