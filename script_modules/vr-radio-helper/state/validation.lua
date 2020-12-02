local Globals = require("vr-radio-helper.globals")
local ComFrequencyValidator = require("vr-radio-helper.components.validators.com_frequency_validator")
local NavFrequencyValidator = require("vr-radio-helper.components.validators.nav_frequency_validator")
local TransponderValidator = require("vr-radio-helper.components.validators.transponder_code_validator")
local BaroValidator = require("vr-radio-helper.components.validators.baro_validator")

local M = {}
M.bootstrap = function()
	M.transponderCodeValidator = TransponderValidator:new()
	M.comFrequencyValidator = ComFrequencyValidator:new()
	M.navFrequencyValidator = NavFrequencyValidator:new()
	M.baroValidator = BaroValidator:new()
end
return M
