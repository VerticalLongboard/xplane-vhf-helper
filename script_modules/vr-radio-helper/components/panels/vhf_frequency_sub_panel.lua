local Globals = require("vr-radio-helper.globals")
local NumberSubPanel = require("vr-radio-helper.components.panels.number_sub_panel")
local SpeakNato = require("vr-radio-helper.components.speak_nato")
local Config = require("vr-radio-helper.state.config")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local LuaPlatform = require("lua_platform")

local VhfFrequencySubPanel
do
    VhfFrequencySubPanel = NumberSubPanel:new()

    Globals._NEWFUNC(VhfFrequencySubPanel._getCurrentCleanLinkedValueString)
    function VhfFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
        assert(nil)
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._setCleanLinkedValueString)
    function VhfFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
        assert(nil)
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.new)
    function VhfFrequencySubPanel:new(
        newValidator,
        newFirstVhfLinkedDataref,
        newSecondVhfLinkedDataref,
        newPanelTitle,
        newDescriptor)
        local newInstanceWithState = NumberSubPanel:new(newPanelTitle, newValidator)

        newInstanceWithState.Constants.FullyPaddedFreqString = "---.---"

        newInstanceWithState.linkedDatarefs = {newFirstVhfLinkedDataref, newSecondVhfLinkedDataref}
        newInstanceWithState.descriptor = newDescriptor

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.addCharacter)
    function VhfFrequencySubPanel:addCharacter(character)
        if (string.len(self.enteredValue) == 7) then
            return
        end

        if (string.len(self.enteredValue) == 3) then
            self.enteredValue = self.enteredValue .. "."
        end

        self.enteredValue = self.enteredValue .. character
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.numberCanBeSetNow)
    function VhfFrequencySubPanel:numberCanBeSetNow()
        return (self.enteredValue:len() > 3)
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.backspace)
    function VhfFrequencySubPanel:backspace()
        self.enteredValue = self.enteredValue:sub(1, -2)
        if (self.enteredValue:len() == 4) then
            self.enteredValue = self.enteredValue:sub(1, -2)
        end
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._validateAndSetNextVHFFrequency)
    function VhfFrequencySubPanel:_validateAndSetNextVHFFrequency(vhfNumber)
        if (not self:numberCanBeSetNow()) then
            return
        end

        local autocompleted = self.inputPanelValidator:autocomplete(self.enteredValue)
        local cleanVhfFrequency = autocompleted:gsub("%.", "")
        self:_setCleanLinkedValueString(vhfNumber, cleanVhfFrequency)
        if (Config.Config:getSpeakNumbersLocally()) then
            SpeakNato.speakFrequency(autocompleted)
        end

        self.enteredValue = Globals.emptyString
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._renderTinyFontLine)
    function VhfFrequencySubPanel:_renderTinyFontLineCentered(centerText, centerColor)
        if (centerText:len() > 34) then
            centerText = ("%.31s..."):format(centerText)
        end
        if (centerColor == nil) then
            centerColor = Globals.Colors.greyText
        end

        local tinyFontLinePadding = 34 - centerText:len()
        local leftPadding = nil
        local rightPadding = nil
        if (tinyFontLinePadding % 2 == 0) then
            leftPadding = tinyFontLinePadding * 0.5
            rightPadding = leftPadding
        else
            leftPadding = math.floor(tinyFontLinePadding * 0.5)
            rightPadding = leftPadding + 1
        end

        local padWhitespaceLeft = string.rep(" ", leftPadding)
        local padWhitespaceRight = string.rep(" ", rightPadding)

        imgui.SetWindowFontScale(0.5 * globalFontScale)

        local centerText = ("%s%s%s"):format(padWhitespaceLeft, centerText, padWhitespaceRight)

        imgui.PushStyleColor(imgui.constant.Col.Text, centerColor)
        imgui.TextUnformatted(centerText)
        imgui.PopStyleColor()
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._renderTinyFontLine)
    function VhfFrequencySubPanel:_renderTinyFontLine(leftText, rightText, leftColor, rightColor)
        if (leftColor == nil) then
            leftColor = Globals.Colors.greyText
        end
        if (rightColor == nil) then
            rightColor = Globals.Colors.greyText
        end

        local text = nil
        if (leftText:len() > 16) then
            leftText = ("%.13s..."):format(leftText)
        end
        if (rightText:len() > 16) then
            rightText = ("%.13s..."):format(rightText)
        end

        local colorDiffers = false

        local tinyFontLinePadding = 34 - leftText:len() - rightText:len()

        local padWhitespace = ""
        if (tinyFontLinePadding >= 0) then
            for i = 1, tinyFontLinePadding do
                padWhitespace = padWhitespace .. " "
            end

            if (leftColor ~= rightColor) then
                colorDiffers = true
            else
                text = ("%s%s%s"):format(leftText, padWhitespace, rightText)
            end
        else
            text = "<<<LINE STILL TOO LONG>>>"
        end

        imgui.SetWindowFontScale(0.5 * globalFontScale)

        if (colorDiffers) then
            imgui.PushStyleColor(imgui.constant.Col.Text, leftColor)
            imgui.TextUnformatted(leftText)
            imgui.SameLine()
            imgui.TextUnformatted(padWhitespace)
            imgui.PopStyleColor()
            imgui.PushStyleColor(imgui.constant.Col.Text, rightColor)
            imgui.SameLine()
            imgui.TextUnformatted(rightText)
            imgui.PopStyleColor()
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, leftColor)
            imgui.TextUnformatted(text)
            imgui.PopStyleColor()
        end
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._getFullLinkedValueString)
    function VhfFrequencySubPanel:_getFullLinkedValueString(vhfNumber)
        local cleanValueString = self:_getCurrentCleanLinkedValueString(vhfNumber)
        return cleanValueString:sub(1, 3) .. Globals.decimalCharacter .. cleanValueString:sub(4, 7)
    end

    Globals._NEWFUNC(VhfFrequencySubPanel._renderValueLine)
    function VhfFrequencySubPanel:_renderValueLine()
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        local vhf1String = self:_getFullLinkedValueString(1)
        if (self.inputPanelValidator:validate(vhf1String) == nil) then
            vhf1String = self.Constants.FullyPaddedFreqString
        end

        local vhf2String = self:_getFullLinkedValueString(2)
        if (self.inputPanelValidator:validate(vhf2String) == nil) then
            vhf2String = self.Constants.FullyPaddedFreqString
        end

        local bigFontLinePadding = 17 - vhf1String:len() - vhf2String:len()
        padWhitespace = ""
        for i = 1, bigFontLinePadding do
            padWhitespace = padWhitespace .. " "
        end

        self:_pushBlinkingCurrentValueColor(self.linkedDatarefs[1])
        imgui.TextUnformatted(vhf1String)
        imgui.PopStyleColor()
        imgui.SameLine()
        imgui.TextUnformatted(padWhitespace)
        imgui.SameLine()
        self:_pushBlinkingCurrentValueColor(self.linkedDatarefs[2])
        imgui.TextUnformatted(vhf2String)
        imgui.PopStyleColor()
    end

    function VhfFrequencySubPanel:_renderSwitchButton(nextVhfFrequencyIsSettable, vhfNumber)
        imgui.SetWindowFontScale(0.9 * globalFontScale)
        Globals.ImguiUtils.pushSwitchButtonColors(nextVhfFrequencyIsSettable)

        if (imgui.Button("<" .. tonumber(vhfNumber) .. ">")) then
            self:_validateAndSetNextVHFFrequency(vhfNumber)
        end

        Globals.ImguiUtils.popSwitchButtonColors()
    end

    function VhfFrequencySubPanel:_renderNextValueLine(upperTinyFontText, lowerTinyFontText)
        local nextVhfFrequencyIsSettable = self:numberCanBeSetNow()

        imgui.Dummy(0.0, 1.0)
        imgui.Separator()

        upperTinyFontText = upperTinyFontText or ""
        self:_renderTinyFontLineCentered(upperTinyFontText)

        imgui.SetWindowFontScale(1.0 * globalFontScale)

        self:_renderSwitchButton(nextVhfFrequencyIsSettable, 1)

        local dummyPadding = 33.0

        imgui.SameLine()
        imgui.Dummy(dummyPadding, 0.0)

        Globals.ImguiUtils.pushNextValueColor(nextVhfFrequencyIsSettable)

        imgui.SetWindowFontScale(1.0 * globalFontScale)
        local paddedFreqString =
            self.enteredValue .. self.Constants.FullyPaddedFreqString:sub(string.len(self.enteredValue) + 1, 7)
        imgui.SameLine()
        imgui.TextUnformatted(paddedFreqString)

        imgui.PopStyleColor()

        imgui.SameLine()
        imgui.Dummy(dummyPadding, 0.0)

        imgui.SameLine()
        self:_renderSwitchButton(nextVhfFrequencyIsSettable, 2)

        lowerTinyFontText = lowerTinyFontText or ""
        self:_renderTinyFontLineCentered(lowerTinyFontText)
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.renderToCanvas)
    function VhfFrequencySubPanel:renderToCanvas()
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        self:_renderTinyFontLine("", "")
        self:_renderValueLine()
        self:_renderTinyFontLine(self.descriptor .. "1", self.descriptor .. "2")
        self:_renderNextValueLine()

        imgui.PopStyleVar()
        imgui.PopStyleVar()

        imgui.Separator()
        self:_renderNumberPanel()
    end
end

return VhfFrequencySubPanel
