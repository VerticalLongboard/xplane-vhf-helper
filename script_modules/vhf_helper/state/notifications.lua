local VhfHelperNotificationManager = require("vhf_helper.components.vhf_helper_notification_manager")
local Config = require("vhf_helper.state.config")

local M = {}
M.bootstrap = function()
    -- M.notificationManager = VhfHelperNotificationManager:new()
    logMsg("config notifications?=" .. tostring(Config.Config.Content.Notifications))
    -- M.notificationManager:loadState(Config.Config.Content.Notifications)
end
return M
