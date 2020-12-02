local Globals = require("vr-radio-helper.globals")
local VhfFrequencySubPanel = require("vr-radio-helper.components.panels.vhf_frequency_sub_panel")

local NavFrequencySubPanel
do
    NavFrequencySubPanel = VhfFrequencySubPanel:new()

    Globals.OVERRIDE(NavFrequencySubPanel._getCurrentCleanLinkedValueString)
    function NavFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
        return tostring(self.linkedDatarefs[vhfNumber]:getLinkedValue()) .. "0"
    end

    Globals.OVERRIDE(NavFrequencySubPanel._setCleanLinkedValueString)
    function NavFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
        cleanValueString = cleanValueString:sub(1, 5)
        local nextFrequencyAsNumber = tonumber(cleanValueString)
        self.linkedDatarefs[vhfNumber]:emitNewValue(nextFrequencyAsNumber)
    end
end
return NavFrequencySubPanel
