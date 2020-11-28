local Globals = require("vhf_helper.globals")
local NumberSubPanel = require("vhf_helper.components.number_sub_panel")
local SpeakNato = require("vhf_helper.components.speak_nato")
local Config = require("vhf_helper.state.config")
local Utilities = require("shared_components.utilities")

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
    function VhfFrequencySubPanel:new(newValidator, newFirstVhfLinkedDataref, newSecondVhfLinkedDataref, newDescriptor)
        local newInstanceWithState = NumberSubPanel:new(newValidator)

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

    function VhfFrequencySubPanel:_renderTinyFontLine(leftText, rightText)
        local tinyFontLinePadding = 34 - leftText:len() - rightText:len()
        local padWhitespace = ""
        for i = 1, tinyFontLinePadding do
            padWhitespace = padWhitespace .. " "
        end
        imgui.SetWindowFontScale(0.5 * globalFontScale)
        imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.greyText)
        imgui.TextUnformatted(leftText .. padWhitespace .. rightText)
        imgui.PopStyleColor()
    end

    function VhfFrequencySubPanel:_renderValueLine()
        imgui.SetWindowFontScale(1.0 * globalFontScale)
        imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)

        local vhf1String = self:_getCurrentCleanLinkedValueString(1)
        vhf1String = vhf1String:sub(1, 3) .. Globals.decimalCharacter .. vhf1String:sub(4, 7)
        if (self.inputPanelValidator:validate(vhf1String) == nil) then
            vhf1String = self.Constants.FullyPaddedFreqString
        end

        local vhf2String = self:_getCurrentCleanLinkedValueString(2)
        vhf2String = vhf2String:sub(1, 3) .. Globals.decimalCharacter .. vhf2String:sub(4, 7)
        if (self.inputPanelValidator:validate(vhf2String) == nil) then
            vhf2String = self.Constants.FullyPaddedFreqString
        end

        local bigFontLinePadding = 17 - vhf1String:len() - vhf2String:len()
        padWhitespace = ""
        for i = 1, bigFontLinePadding do
            padWhitespace = padWhitespace .. " "
        end

        imgui.TextUnformatted(vhf1String)
        imgui.SameLine()
        imgui.TextUnformatted(padWhitespace)
        imgui.SameLine()
        imgui.TextUnformatted(vhf2String)

        imgui.PopStyleColor()
    end

    function VhfFrequencySubPanel:_renderSwitchButton(nextVhfFrequencyIsSettable, vhfNumber)
        imgui.SetWindowFontScale(1.0 * globalFontScale)
        Globals.ImguiUtils:pushSwitchButtonColors(nextVhfFrequencyIsSettable)

        if (imgui.Button("<" .. tonumber(vhfNumber) .. ">")) then
            self:_validateAndSetNextVHFFrequency(vhfNumber)
        end

        Globals.ImguiUtils:popSwitchButtonColors()
    end

    function VhfFrequencySubPanel:_renderNextValueLine()
        local nextVhfFrequencyIsSettable = self:numberCanBeSetNow()

        imgui.Dummy(0.0, 1.0)
        imgui.Separator()

        imgui.SetWindowFontScale(1.0 * globalFontScale)

        self:_renderSwitchButton(nextVhfFrequencyIsSettable, 1)

        imgui.SameLine()
        imgui.TextUnformatted("  ")

        if (nextVhfFrequencyIsSettable) then
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
        end

        imgui.SetWindowFontScale(1.0 * globalFontScale)
        local paddedFreqString =
            self.enteredValue .. self.Constants.FullyPaddedFreqString:sub(string.len(self.enteredValue) + 1, 7)
        imgui.SameLine()
        imgui.TextUnformatted(paddedFreqString)

        imgui.PopStyleColor()

        imgui.SameLine()
        imgui.TextUnformatted("  ")

        imgui.SameLine()
        self:_renderSwitchButton(nextVhfFrequencyIsSettable, 2)
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
