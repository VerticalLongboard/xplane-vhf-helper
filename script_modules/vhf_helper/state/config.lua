local Configuration = require("vhf_helper.components.configuration")

local M = {}
M.bootstrap = function()
    M.Config = Configuration:new(SCRIPT_DIRECTORY .. "vhf_helper.ini")
end
return M
