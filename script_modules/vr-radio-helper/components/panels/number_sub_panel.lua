local Globals = require("vr-radio-helper.globals")
local SubPanel = require("vr-radio-helper.components.panels.sub_panel")
local Validation = require("vr-radio-helper.state.validation")
local LuaPlatform = require("lua_platform")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local FlexibleLength1DSpring = require("vr-radio-helper.shared_components.flexible_length_1d_spring")

local NumberSubPanel
do
    NumberSubPanel = SubPanel:new()

    NumberSubPanel.Constants = {
        ClearButtonTitle = "Clr",
        BackspaceButtonTitle = "Del",
        DefaultSpecialButtonWidth = 52.0,
        DefaultSpecialButtonHeight = 33.0
    }

    function NumberSubPanel:new(newPanelTitle, newValidator)
        local newInstanceWithState = SubPanel:new(newPanelTitle)
        newInstanceWithState.enteredValue = Globals.emptyString
        newInstanceWithState.inputPanelValidator = newValidator
        newInstanceWithState.buttonStyleSprings = {}

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function NumberSubPanel:getEnteredValue()
        return self.enteredValue
    end

    function NumberSubPanel:addCharacter(character)
        assert(nil)
    end

    function NumberSubPanel:numberCanBeSetNow()
        assert(nil)
    end

    function NumberSubPanel:backspace()
        self.enteredValue = self.enteredValue:sub(1, -2)
    end

    function NumberSubPanel:clear()
        self.enteredValue = Globals.emptyString
    end

    Globals.OVERRIDE(NumberSubPanel.show)
    function NumberSubPanel:show()
        self:_resetButtonStyleSpringsToDisabled()
    end

    function NumberSubPanel:_resetButtonStyleSpringsToDisabled()
        for _, spring in ipairs(self.buttonStyleSprings) do
            spring:overrideCurrentPosition(0.0)
            spring:setTarget(0.0)
        end
    end

    function NumberSubPanel:_renderNumberButtonsInSameLine(fromIndex, toIndex)
        for i = fromIndex, toIndex do
            imgui.SameLine()
            self:_createNumberButtonAndReactToClicks(i)
        end
    end

    function NumberSubPanel:_getBlinkingCurrentValueColor(linkedDataref)
        if (LuaPlatform.Time.now() - linkedDataref:getLastLinkedChangeTimestamp() < Globals.linkedValuesChangeBlinkTime) then
            return Utilities.getBlinkingColor(Globals.Colors.a320Orange, 0.5, 20.0)
        else
            return Globals.Colors.a320Orange
        end
    end

    function NumberSubPanel:_pushBlinkingCurrentValueColor(linkedDataref)
        imgui.PushStyleColor(imgui.constant.Col.Text, self:_getBlinkingCurrentValueColor(linkedDataref))
    end

    Globals.OVERRIDE(NumberSubPanel.loop)
    function NumberSubPanel:loop(frameTime)
        SubPanel.loop(self, frameTime)
        self:_updateStyleSprings(frameTime)
    end

    function NumberSubPanel:_renderNumberPanel()
        local leftSideDummyScale = 0.3 * globalFontScale
        local rightSideDummyScale = 0.1 * globalFontScale

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(1, 3)

        local clearingEnabled = self.enteredValue:len() > 0

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        self:_pushButtonSettings(10, clearingEnabled)
        if
            (imgui.Button(
                NumberSubPanel.Constants.BackspaceButtonTitle,
                self.Constants.DefaultSpecialButtonWidth,
                self.Constants.DefaultSpecialButtonHeight
            ))
         then
            self.buttonStyleSprings[10 + 1]:overrideCurrentPosition(0.0)
            self:backspace()
        end
        self:_popButtonSettings()

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(4, 6)

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        self:_pushButtonSettings(11, clearingEnabled)
        if
            (imgui.Button(
                NumberSubPanel.Constants.ClearButtonTitle,
                self.Constants.DefaultSpecialButtonWidth,
                self.Constants.DefaultSpecialButtonHeight
            ))
         then
            self.buttonStyleSprings[11 + 1]:overrideCurrentPosition(0.0)
            self:clear()
        end
        self:_popButtonSettings()

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(7, 9)

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize, Globals.defaultDummySize)
        imgui.SameLine()

        self:_createNumberButtonAndReactToClicks(0)
    end

    function NumberSubPanel:_getButtonStyleSpring(springId)
        local spring = self.buttonStyleSprings[springId]
        if (self.buttonStyleSprings[springId] == nil) then
            self.buttonStyleSprings[springId] = FlexibleLength1DSpring:new(200.0, 0.2)
            spring = self.buttonStyleSprings[springId]
        end
        return spring
    end

    function NumberSubPanel:_updateStyleSprings(frameTime)
        for _, spring in ipairs(self.buttonStyleSprings) do
            spring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        end
    end

    function NumberSubPanel:_pushButtonSettings(id, enabled)
        local spring = self:_getButtonStyleSpring(id + 1)
        if (enabled) then
            spring:setTarget(1.0)
        else
            spring:setTarget(0.0)
        end

        local springPos = spring:getCurrentPosition()
        springPos = math.max(springPos, 0.0)
        springPos = math.min(springPos, 1.0)
        local textColor = Utilities.lerpColors(0xFF444444, Globals.Colors.a320Blue, springPos)
        local buttonColor = Utilities.lerpColors(0xFF222222, Globals.Colors.defaultImguiButtonBackground, springPos)
        local buttonActiveColor =
            Utilities.lerpColors(0xFF222222, Globals.Colors.slightlyBrighterDefaultButtonColor, springPos)
        local buttonHoveredColor =
            Utilities.lerpColors(0xFF222222, Globals.Colors.slightlyBrighterDefaultButtonColor, springPos)

        local borderColor =
            Utilities.lerpColors(
            Globals.Colors.defaultImguiBackground,
            Globals.Colors.defaultImguiButtonBackground,
            springPos
        )
        local frameRounding = Utilities.Math.lerp(4.0, 2.0, springPos)
        local frameBorderSize = Utilities.Math.lerp(1.0, 0.0, springPos)
        local fontSize = Utilities.Math.lerp(0.95 * globalFontScale, 1.0 * globalFontScale, springPos)

        if (id > 9) then
            fontSize = 1.0 * globalFontScale
            frameBorderSize = 0.0
        end

        imgui.SetWindowFontScale(fontSize)

        imgui.PushStyleVar(imgui.constant.StyleVar.FrameRounding, frameRounding)
        imgui.PushStyleVar(imgui.constant.StyleVar.FrameBorderSize, frameBorderSize)

        imgui.PushStyleColor(imgui.constant.Col.Border, borderColor)
        imgui.PushStyleColor(imgui.constant.Col.Text, textColor)
        imgui.PushStyleColor(imgui.constant.Col.Button, buttonColor)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, buttonActiveColor)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, buttonHoveredColor)
    end

    function NumberSubPanel:_popButtonSettings()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()

        imgui.PopStyleVar()
        imgui.PopStyleVar()
    end

    function NumberSubPanel:_createNumberButtonAndReactToClicks(number)
        local numberCharacter = self.inputPanelValidator:getValidNumberCharacterOrNil(self.enteredValue, number)
        local enabled = true

        self:_pushButtonSettings(number, numberCharacter ~= nil)

        if
            (imgui.Button(tostring(number), Globals.defaultDummySize, Globals.defaultDummySize) and
                numberCharacter ~= nil)
         then
            self.buttonStyleSprings[number + 1]:overrideCurrentPosition(0.0)
            self:addCharacter(numberCharacter)
        end

        self:_popButtonSettings()
    end
end

return NumberSubPanel
