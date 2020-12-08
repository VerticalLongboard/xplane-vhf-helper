local Globals = require("vr-radio-helper.globals")
local VhfFrequencySubPanel = require("vr-radio-helper.components.panels.vhf_frequency_sub_panel")
local StationInfo = require("vr-radio-helper.state.station_info")

local ComFrequencySubPanel
do
    ComFrequencySubPanel = VhfFrequencySubPanel:new()

    ComFrequencySubPanel.UnicomFrequencies = {}

    -- https://www.aopa.org/advocacy/advocacy-briefs/air-traffic-services-process-brief-changing-unicom-frequencies
    ComFrequencySubPanel.UnicomFrequencies["122.800"] = {}
    ComFrequencySubPanel.UnicomFrequencies["122.700"] = {}
    ComFrequencySubPanel.UnicomFrequencies["123.000"] = {}
    ComFrequencySubPanel.UnicomFrequencies["122.725"] = {}
    ComFrequencySubPanel.UnicomFrequencies["122.975"] = {}
    ComFrequencySubPanel.UnicomFrequencies["123.050"] = {}
    ComFrequencySubPanel.UnicomFrequencies["123.075"] = {}

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
        if (self.enteredValue:len() > 3) then
            StationInfo.update(self.inputPanelValidator:autocomplete(self.enteredValue))
        end
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
            atcStationId1, atcStationName1, atcStationColor1 =
                self:_getStationInfoForFrequency(self:_getFullLinkedValueString(1), 1)
            atcStationId2, atcStationName2, atcStationColor2 =
                self:_getStationInfoForFrequency(self:_getFullLinkedValueString(2), 2)
            atcStationIdNext, atcStationNameNext, atcStationColorNext =
                self:_getStationInfoForFrequency(self.inputPanelValidator:autocomplete(self.enteredValue))
        else
            atcStationId1 = ("%s1"):format(self.descriptor)
            atcStationId2 = ("%s2"):format(self.descriptor)
        end

        self:_renderTinyFontLine(atcStationName1, atcStationName2, atcStationColor1, atcStationColor2)
        self:_renderValueLine()
        self:_renderTinyFontLine(atcStationId1, atcStationId2, atcStationColor1, atcStationColor2)
        if (self.enteredValue:len() > 3) then
            self:_renderNextValueLine(atcStationNameNext, atcStationIdNext)
        else
            self:_renderNextValueLine()
        end

        imgui.PopStyleVar()
        imgui.PopStyleVar()

        imgui.Separator()
        self:_renderNumberPanel()
    end

    function ComFrequencySubPanel:_getStationInfoForFrequency(fullString, comNumber)
        local atcInfo = StationInfo.getInfoForFrequency(fullString)

        local isUnicom = self.UnicomFrequencies[fullString] ~= nil

        local atcStationName = ""
        local atcStationColor = Globals.Colors.greyText
        if (atcInfo ~= nil) then
            atcStationId = atcInfo.id
            atcStationName = atcInfo.shortReadableName or ""
            atcStationColor = Globals.Colors.darkerOrange
        else
            local idText = nil
            if (isUnicom) then
                idText = "Unicom"
            else
                idText = "UNKNOWN"
            end

            if (comNumber == nil) then
                atcStationId = ("%s: %s"):format(self.descriptor, idText)
            else
                atcStationId = ("%s%d: %s"):format(self.descriptor, comNumber, idText)
            end
        end

        if (isUnicom) then
            atcStationColor = Globals.Colors.darkerBlue
        end

        return atcStationId, atcStationName, atcStationColor
    end
end

return ComFrequencySubPanel
