local Globals = require("vhf_helper.globals")
require("vhf_helper.components.com_frequency_validator")
require("vhf_helper.components.nav_frequency_validator")
require("vhf_helper.components.transponder_validator")

local M = {}
M.bootstrap = function()
	M.transponderCodeValidator = TransponderValidator:new()
	M.comFrequencyValidator = ComFrequencyValidator:new()
	M.navFrequencyValidator = NavFrequencyValidator:new()
end
return M
