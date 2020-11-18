local Validation = require("vhf_helper.validation")
local Datarefs = require("vhf_helper.datarefs")
require("vhf_helper.components.com_frequency_sub_panel")
require("vhf_helper.components.nav_frequency_sub_panel")
require("vhf_helper.components.transponder_code_sub_panel")

local M = {}

M.bootstrap = function()
    M.comFrequencyPanel =
        ComFrequencySubPanel:new(
        Validation.comFrequencyValidator,
        Datarefs.COMLinkedDatarefs[1],
        Datarefs.COMLinkedDatarefs[2],
        "COM"
    )
    M.navFrequencyPanel =
        NavFrequencySubPanel:new(
        Validation.navFrequencyValidator,
        Datarefs.NAVLinkedDatarefs[1],
        Datarefs.NAVLinkedDatarefs[2],
        "NAV"
    )
    M.transponderCodePanel =
        TransponderCodeSubPanel:new(
        Validation.transponderCodeValidator,
        Datarefs.TransponderCodeLinkedDataref,
        Datarefs.TransponderModeLinkedDataref,
        "XPDR"
    )
end
return M
