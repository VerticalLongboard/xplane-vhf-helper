local Globals = require("vhf_helper.globals")
local Datarefs = require("vhf_helper.state.datarefs")
local NumberSubPanel = require("vhf_helper.components.number_sub_panel")
local SpeakNato = require("vhf_helper.components.speak_nato")
local Config = require("vhf_helper.state.config")
local Utilities = require("shared_components.utilities")

local BaroSubPanel
do
    BaroSubPanel = NumberSubPanel:new()

    Globals.OVERRIDE(BaroSubPanel.new)
    function BaroSubPanel:new(newValidator, baroLinkedDatarefs, newDescriptor)
        local newInstanceWithState = NumberSubPanel:new(newValidator)

        newInstanceWithState.Constants.FullyPaddedString = "----"

        newInstanceWithState.linkedDatarefs = baroLinkedDatarefs
        newInstanceWithState.descriptor = newDescriptor

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    Globals.OVERRIDE(BaroSubPanel.addCharacter)
    function BaroSubPanel:addCharacter(character)
        if (self.enteredValue:len() == 4) then
            return
        end

        self.enteredValue = self.enteredValue .. character
    end

    Globals._NEWFUNC(BaroSubPanel._getCurrentLinkedValueString)
    function BaroSubPanel:_getCurrentLinkedValueString(baroNumber)
        local hPa = Globals.convertHgToHpa(self.linkedDatarefs[baroNumber]:getLinkedValue())
        hPa = Utilities.roundFloatingPointToNearestInteger(hPa)
        local hPaString = tostring(hPa)
        if (hPa < 1000 and hPaString:len() == 3) then
            hPaString = "0" .. hPaString
        end

        if (hPaString:len() > 4) then
            hPaString = hPaString:sub(1, 4)
        end

        return hPaString
    end

    Globals.OVERRIDE(BaroSubPanel.numberCanBeSetNow)
    function BaroSubPanel:numberCanBeSetNow()
        local firstDigit = self.enteredValue:sub(1, 1)
        if (firstDigit == "0" or firstDigit == "1") then
            return (self.enteredValue:len() == 4)
        else
            return (self.enteredValue:len() == 3)
        end
    end

    Globals._NEWFUNC(BaroSubPanel._validateAndSetNext)
    function BaroSubPanel:_validateAndSetNext(baroNumber)
        if (not self:numberCanBeSetNow()) then
            return
        end

        local autocompleted = self.inputPanelValidator:autocomplete(self.enteredValue)
        local hg = Globals.convertHpaToHg(tonumber(autocompleted))
        self.linkedDatarefs[baroNumber]:emitNewValue(hg)
        if (Config.Config:getSpeakNumbersLocally()) then
            SpeakNato.speakQnh(autocompleted)
        end

        self.enteredValue = Globals.emptyString
    end

    Globals._NEWFUNC(BaroSubPanel._buildCurrentTransponderLine)
    function BaroSubPanel:_renderOneBarometerBlock(nextValueIsSettable, baroNumber)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        imgui.SetWindowFontScale(0.5 * globalFontScale)

        imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.greyText)
        if (baroNumber < 3) then
            imgui.TextUnformatted("B" .. tostring(baroNumber) .. " ")
        else
            imgui.TextUnformatted("\nSTBY ")
        end
        imgui.PopStyleColor()

        self:_pushBlinkingCurrentValueColor(self.linkedDatarefs[baroNumber])

        local currentString = self:_getCurrentLinkedValueString(baroNumber)
        if (self.inputPanelValidator:validate(currentString) == nil) then
            currentString = self.Constants.FullyPaddedString
        end

        imgui.SetWindowFontScale(1.0 * globalFontScale)
        imgui.SameLine()
        imgui.TextUnformatted(currentString)
        imgui.PopStyleColor()

        imgui.SetWindowFontScale(0.5 * globalFontScale)
        imgui.SameLine()
        imgui.TextUnformatted(" ")

        imgui.SetWindowFontScale(0.8 * globalFontScale)
        Globals.ImguiUtils.pushSwitchButtonColors(nextValueIsSettable)
        buttonText = imgui.SameLine()
        if (imgui.Button("<" .. tostring(baroNumber) .. ">")) then
            self:_validateAndSetNext(baroNumber)
        end
        Globals.ImguiUtils.popSwitchButtonColors()

        imgui.PopStyleVar()
    end

    Globals.OVERRIDE(BaroSubPanel.renderToCanvas)
    function BaroSubPanel:renderToCanvas()
        imgui.SetWindowFontScale(1.0 * globalFontScale)

        local nextValueIsSettable = self:numberCanBeSetNow()

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
        imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

        self:_renderOneBarometerBlock(nextValueIsSettable, 1)

        imgui.SetWindowFontScale(0.5 * globalFontScale)
        imgui.SameLine()
        imgui.TextUnformatted(" ")
        imgui.SameLine()
        self:_renderOneBarometerBlock(nextValueIsSettable, 2)

        imgui.TextUnformatted("          ")
        imgui.SameLine()
        self:_renderOneBarometerBlock(nextValueIsSettable, 3)

        imgui.SetWindowFontScale(1.0 * globalFontScale)
        imgui.Dummy(0.0, 3.0)
        imgui.Separator()

        imgui.SetWindowFontScale(1.0 * globalFontScale)

        imgui.TextUnformatted("New " .. self.descriptor .. "     ")

        Globals.ImguiUtils.pushNextValueColor(nextValueIsSettable)
        
        imgui.SameLine()
        local paddedString = nil
        local firstDigit = self.enteredValue:sub(1, 1)
        if (firstDigit == "8" or firstDigit == "9") then
            paddedString =
                " " .. self.enteredValue .. self.Constants.FullyPaddedString:sub(self.enteredValue:len() + 1, 3)
        else
            paddedString = self.enteredValue .. self.Constants.FullyPaddedString:sub(self.enteredValue:len() + 1, 4)
        end
        imgui.TextUnformatted(paddedString)

        imgui.PopStyleColor()

        imgui.PopStyleVar()
        imgui.PopStyleVar()

        imgui.Separator()
        self:_renderNumberPanel()
    end
end

return BaroSubPanel
