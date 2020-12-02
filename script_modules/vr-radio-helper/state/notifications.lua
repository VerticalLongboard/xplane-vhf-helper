local VhfHelperNotificationManager = require("vr-radio-helper.components.vhf_helper_notification_manager")
local Config = require("vr-radio-helper.state.config")
local M = {}
M.bootstrap = function()
    M.manager = VhfHelperNotificationManager:new()
    M.manager:loadState(Config.Config.Content.Notifications)
end
return M
