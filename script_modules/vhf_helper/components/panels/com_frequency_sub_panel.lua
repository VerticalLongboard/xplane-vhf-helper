local Globals = require("vhf_helper.globals")
local VhfFrequencySubPanel = require("vhf_helper.components.panels.vhf_frequency_sub_panel")
local StationInfo = require("vhf_helper.state.station_info")

local ComFrequencySubPanel
do
    ComFrequencySubPanel = VhfFrequencySubPanel:new()

    Globals.OVERRIDE(ComFrequencySubPanel.show)
    function ComFrequencySubPanel:show()
        VhfFrequencySubPanel.show(self)
    end

    Globals._NEWFUNC(ComFrequencySubPanel.overrideEnteredValue)
    function ComFrequencySubPanel:overrideEnteredValue(newValue)
        self.enteredValue = newValue
        VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
    end

    function ComFrequencySubPanel:triggerStationInfoUpdate()
        StationInfo.update(self:_getFullLinkedValueString(1))
        StationInfo.update(self:_getFullLinkedValueString(2))
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

    Globals.OVERRIDE(ComFrequencySubPanel.renderToCanvas)
    function ComFrequencySubPanel:renderToCanvas()
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        local atcStationId1 = nil
        local atcStationName1 = ""
        local atcStationColor1 = Globals.Colors.greyText
        local atcStationId2 = nil
        local atcStationName2 = ""
        local atcStationColor2 = Globals.Colors.greyText

        if (StationInfo.isVatsimbriefHelperAvailable()) then
            local atcInfo1 = StationInfo.getInfoForFrequency(self:_getFullLinkedValueString(1))
            local atcInfo2 = StationInfo.getInfoForFrequency(self:_getFullLinkedValueString(2))

            if (atcInfo1 ~= nil) then
                atcStationId1 = atcInfo1.id
                atcStationName1 = atcInfo1.shortReadableName or ""
                atcStationColor1 = Globals.Colors.darkerOrange
            else
                atcStationId1 = ("%s1: UNKNOWN"):format(self.descriptor)
            end

            if (atcInfo2 ~= nil) then
                atcStationId2 = atcInfo2.id
                atcStationName2 = atcInfo2.shortReadableName or ""
                atcStationColor2 = Globals.Colors.darkerOrange
            else
                atcStationId2 = ("%s2: UNKNOWN"):format(self.descriptor)
            end
        else
            atcStationId1 = ("%s1"):format(self.descriptor)
            atcStationId2 = ("%s2"):format(self.descriptor)
        end

        self:_renderTinyFontLine(atcStationName1, atcStationName2, atcStationColor1, atcStationColor2)
        self:_renderValueLine()
        self:_renderTinyFontLine(atcStationId1, atcStationId2, atcStationColor1, atcStationColor2)
        self:_renderNextValueLine()

        imgui.PopStyleVar()
        imgui.PopStyleVar()

        imgui.Separator()
        self:_renderNumberPanel()
    end
end

return ComFrequencySubPanel
