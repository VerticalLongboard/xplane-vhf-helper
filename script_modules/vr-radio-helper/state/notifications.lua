local ConfigurationStorageNotificationManager =
    require("vr-radio-helper.shared_components.configuration_storage_notification_manager")
local Config = require("vr-radio-helper.state.config")
local M = {}
M.bootstrap = function()
    M.manager = ConfigurationStorageNotificationManager:new(Config.Config)
end
return M
