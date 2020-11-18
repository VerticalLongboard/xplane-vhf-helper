local Globals = require("vhf_helper.globals")
require("vhf_helper.components.vhf_frequency_sub_panel")

local ComFrequencySubPanelClass
do
    ComFrequencySubPanel = VhfFrequencySubPanel:new()

    Globals._NEWFUNC(ComFrequencySubPanel.overrideEnteredValue)
    function ComFrequencySubPanel:overrideEnteredValue(newValue)
        self.enteredValue = newValue
        VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
    end

    Globals.OVERRIDE(ComFrequencySubPanel.addCharacter)
    function ComFrequencySubPanel:addCharacter(character)
        VhfFrequencySubPanel.addCharacter(self, character)
        VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
    end

    Globals.OVERRIDE(ComFrequencySubPanel.backspace)
    function ComFrequencySubPanel:backspace()
        local lenBefore = self.enteredValue:len()
        VhfFrequencySubPanel.backspace(self)
        if (lenBefore ~= self.enteredValue:len()) then
            VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
        end
    end

    Globals.OVERRIDE(ComFrequencySubPanel.clear)
    function ComFrequencySubPanel:clear()
        local lenBefore = self.enteredValue:len()
        VhfFrequencySubPanel.clear(self)
        if (lenBefore > 0) then
            VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
        end
    end

    Globals.OVERRIDE(ComFrequencySubPanel._getCurrentCleanLinkedValueString)
    function ComFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
        return tostring(self.linkedDatarefs[vhfNumber]:getLinkedValue())
    end

    Globals.OVERRIDE(ComFrequencySubPanel._setCleanLinkedValueString)
    function ComFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
        local nextFrequencyAsNumber = tonumber(cleanValueString)
        self.linkedDatarefs[vhfNumber]:emitNewValue(nextFrequencyAsNumber)

        -- Emit change solely based on the user having pressed a button, especially if the new frequency is equal.
        -- Any real change will emit an event later anyway. This helps with updating button states in external scripts.
        if (self.linkedDatarefs[vhfNumber]:getLinkedValue() == nextFrequencyAsNumber) then
            VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
        end
    end
end
