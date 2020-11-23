local Globals = require("vhf_helper.globals")
local NumberSubPanel = require("vhf_helper.components.number_sub_panel")
local SpeakNato = require("vhf_helper.components.speak_nato")
local Config = require("vhf_helper.state.config")

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

    Globals._NEWFUNC(VhfFrequencySubPanel._buildCurrentVhfLine)
    function VhfFrequencySubPanel:_buildCurrentVhfLine(vhfNumber, nextVhfFrequencyIsSettable)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        imgui.TextUnformatted(self.descriptor .. tonumber(vhfNumber) .. ": ")

        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)

        local currentVhfString = self:_getCurrentCleanLinkedValueString(vhfNumber)
        imgui.TextUnformatted(currentVhfString:sub(1, 3) .. Globals.decimalCharacter .. currentVhfString:sub(4, 7))
        imgui.PopStyleColor()

        imgui.PushStyleColor(imgui.constant.Col.Button, Globals.Colors.a320Green)

        if (nextVhfFrequencyIsSettable) then
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.black)
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.white)
        end

        imgui.SameLine()
        imgui.TextUnformatted(" ")

        local buttonText = "   "
        if (nextVhfFrequencyIsSettable) then
            buttonText = "<" .. tonumber(vhfNumber) .. ">"

            imgui.SameLine()
            if (imgui.Button(buttonText)) then
                self:_validateAndSetNextVHFFrequency(vhfNumber)
            end
        end

        imgui.PopStyleColor()
        imgui.PopStyleColor()

        imgui.PopStyleVar()
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
            SpeakNato:speakFrequency(autocompleted)
        end

        self.enteredValue = Globals.emptyString
    end

    Globals.OVERRIDE(VhfFrequencySubPanel.renderToCanvas)
    function VhfFrequencySubPanel:renderToCanvas()
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        local nextVhfFrequencyIsSettable = self:numberCanBeSetNow()

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)

        self:_buildCurrentVhfLine(1, nextVhfFrequencyIsSettable)
        self:_buildCurrentVhfLine(2, nextVhfFrequencyIsSettable)

        imgui.Separator()

        imgui.TextUnformatted("Next " .. self.descriptor .. ": ")

        if (nextVhfFrequencyIsSettable) then
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
        end

        imgui.SameLine()

        local paddedFreqString =
            self.enteredValue .. self.Constants.FullyPaddedFreqString:sub(string.len(self.enteredValue) + 1, 7)
        imgui.TextUnformatted(paddedFreqString)

        imgui.PopStyleVar()

        imgui.PopStyleColor()

        imgui.Separator()
        self:_renderNumberPanel()
    end
end

return VhfFrequencySubPanel
