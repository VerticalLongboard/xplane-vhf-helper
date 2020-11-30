local Globals = require("vhf_helper.globals")
local VhfFrequencySubPanel = require("vhf_helper.components.vhf_frequency_sub_panel")

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

    function ComFrequencySubPanel:_getInfoForFrequency(fullFrequencyString)
        if (VatsimbriefHelperPublicInterface ~= nil and VatsimbriefHelperPublicInterface.getInterfaceVersion() == 1) then
            local atcInfos =
                VatsimbriefHelperPublicInterface.getAtcStationsForFrequencyClosestFirst(fullFrequencyString)
            if (atcInfos == nil or #atcInfos == 0) then
                local lastDigit = fullFrequencyString:sub(7, 7)
                if (lastDigit == "5") then
                    fullFrequencyString = Globals.replaceCharacter(fullFrequencyString, 7, "0")
                elseif (lastDigit == "0") then
                    fullFrequencyString = Globals.replaceCharacter(fullFrequencyString, 7, "5")
                end
                atcInfos = VatsimbriefHelperPublicInterface.getAtcStationsForFrequencyClosestFirst(fullFrequencyString)
                if (atcInfos == nil or #atcInfos == 0) then
                    return nil
                end
            end
            return atcInfos[1]
        else
            return nil
        end
    end

    function ComFrequencySubPanel:_getShortReadableStationName(longReadableName)
        local firstW = longReadableName:find("%w")
        if (firstW == nil) then
            return ""
        end

        local i = firstW
        local lastNameCharacter = i
        while i <= #longReadableName do
            local char = longReadableName:sub(i, i)
            local matchesW = char:match("%w")
            local matchesWhitespace = char:match("%s")
            if (matchesW) then
                lastNameCharacter = i
            end
            if (matchesW or matchesWhitespace) then
                i = i + 1
            else
                break
            end
        end

        return longReadableName:sub(firstW, lastNameCharacter)
    end

    Globals.OVERRIDE(ComFrequencySubPanel.renderToCanvas)
    function ComFrequencySubPanel:renderToCanvas()
        TRACK_ISSUE("Tech Debt", "Get info only if local linked variable changed.")
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        local atcStationId1 = self.descriptor .. "1"
        local atcStationName1 = ""
        local atcStationId2 = self.descriptor .. "2"
        local atcStationName2 = ""

        local atcInfo1 = self:_getInfoForFrequency(self:_getFullLinkedValueString(1))
        local atcInfo2 = self:_getInfoForFrequency(self:_getFullLinkedValueString(2))

        if (atcInfo1 ~= nil) then
            atcStationId1 = atcInfo1.id
            atcStationName1 = self:_getShortReadableStationName(atcInfo1.readableName)
        end

        if (atcInfo2 ~= nil) then
            atcStationId2 = atcInfo2.id
            atcStationName2 = self:_getShortReadableStationName(atcInfo2.readableName)
        end

        self:_renderTinyFontLine(atcStationName1, atcStationName2)
        self:_renderValueLine()
        self:_renderTinyFontLine(atcStationId1, atcStationId2)
        self:_renderNextValueLine()

        imgui.PopStyleVar()
        imgui.PopStyleVar()

        imgui.Separator()
        self:_renderNumberPanel()
    end
end

return ComFrequencySubPanel
