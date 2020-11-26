local VhfHelperConfiguration = require("vhf_helper.components.vhf_helper_configuration")

local M = {}
M.bootstrap = function()
    M.Config = VhfHelperConfiguration:new(SCRIPT_DIRECTORY .. "vhf_helper.ini")
    M.Config:load()
end
return M
