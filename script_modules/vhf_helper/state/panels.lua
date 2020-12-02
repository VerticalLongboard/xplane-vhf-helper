local Datarefs = require("vhf_helper.state.datarefs")
local Validation = require("vhf_helper.state.validation")

local ComFrequencySubPanel = require("vhf_helper.components.panels.com_frequency_sub_panel")
local NavFrequencySubPanel = require("vhf_helper.components.panels.nav_frequency_sub_panel")
local TransponderCodeSubPanel = require("vhf_helper.components.panels.transponder_code_sub_panel")
local BaroSubPanel = require("vhf_helper.components.panels.baro_sub_panel")

local M = {}

M.bootstrap = function()
    M.comFrequencyPanel =
        ComFrequencySubPanel:new(
        Validation.comFrequencyValidator,
        Datarefs.comLinkedDatarefs[1],
        Datarefs.comLinkedDatarefs[2],
        "COM",
        "COM"
    )
    M.navFrequencyPanel =
        NavFrequencySubPanel:new(
        Validation.navFrequencyValidator,
        Datarefs.navLinkedDatarefs[1],
        Datarefs.navLinkedDatarefs[2],
        "NAV",
        "NAV"
    )
    M.transponderCodePanel =
        TransponderCodeSubPanel:new(
        Validation.transponderCodeValidator,
        Datarefs.TransponderCodeLinkedDataref,
        Datarefs.TransponderModeLinkedDataref,
        "XPDR",
        "TRANSPONDER"
    )
    M.baroPanel = BaroSubPanel:new(Validation.baroValidator, Datarefs.baroLinkedDatarefs, "BARO", "BARO")
end
return M
