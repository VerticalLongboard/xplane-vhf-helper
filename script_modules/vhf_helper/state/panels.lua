local Validation = require("vhf_helper.state.validation")
local Datarefs = require("vhf_helper.state.datarefs")
ComFrequencySubPanel = require("vhf_helper.components.com_frequency_sub_panel")
NavFrequencySubPanel = require("vhf_helper.components.nav_frequency_sub_panel")
TransponderCodeSubPanel = require("vhf_helper.components.transponder_code_sub_panel")

local M = {}

M.bootstrap = function()
    M.comFrequencyPanel =
        ComFrequencySubPanel:new(
        Validation.comFrequencyValidator,
        Datarefs.comLinkedDatarefs[1],
        Datarefs.comLinkedDatarefs[2],
        "COM"
    )
    M.navFrequencyPanel =
        NavFrequencySubPanel:new(
        Validation.navFrequencyValidator,
        Datarefs.navLinkedDatarefs[1],
        Datarefs.navLinkedDatarefs[2],
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
