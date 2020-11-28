local Globals = require("vhf_helper.globals")
local Validation = require("vhf_helper.state.validation")
local LuaPlatform = require("lua_platform")
local Utilities = require("shared_components.utilities")
local FlexibleLength1DSpring = require("shared_components.flexible_length_1d_spring")

local NumberSubPanel
do
    NumberSubPanel = {
        Constants = {
            ClearButtonTitle = "Clr",
            BackspaceButtonTitle = "Del"
        }
    }

    function NumberSubPanel:new(newValidator)
        local newInstanceWithState = {
            enteredValue = Globals.emptyString,
            inputPanelValidator = newValidator,
            buttonStyleSprings = {}
        }
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

    function NumberSubPanel:renderToCanvas()
        assert(nil)
    end

    function NumberSubPanel:_renderNumberButtonsInSameLine(fromIndex, toIndex)
        for i = fromIndex, toIndex do
            imgui.SameLine()
            self:_createNumberButtonAndReactToClicks(i)
        end
    end

    function NumberSubPanel:_getBlinkingCurrentValueColor(linkedDataref)
        if (LuaPlatform.Time.now() - linkedDataref:getLastLinkedChangeTimestamp() < Globals.linkedValuesChangeBlinkTime) then
            return Utilities.getBlinkingColor(Globals.Colors.a320Orange, 0.5, 15.0)
        else
            return Globals.Colors.a320Orange
        end
    end

    function NumberSubPanel:_pushBlinkingCurrentValueColor(linkedDataref)
        imgui.PushStyleColor(imgui.constant.Col.Text, self:_getBlinkingCurrentValueColor(linkedDataref))
    end

    function NumberSubPanel:_renderNumberPanel()
        self:_updateStyleSprings()

        local numberFontScale = 1.3 * globalFontScale

        local leftSideDummyScale = 0.3 * globalFontScale
        local rightSideDummyScale = 0.1 * globalFontScale

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(1, 3)

        local clearingEnabled = self.enteredValue:len() > 0

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        self:_pushColorsForButton(10, clearingEnabled)
        if (imgui.Button(NumberSubPanel.Constants.BackspaceButtonTitle)) then
            self:backspace()
        end
        self:_popButtonColors()

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(4, 6)

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        self:_pushColorsForButton(11, clearingEnabled)
        if (imgui.Button(NumberSubPanel.Constants.ClearButtonTitle)) then
            self:clear()
        end
        self:_popButtonColors()

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
            self.buttonStyleSprings[springId] = FlexibleLength1DSpring:new(10.0, 100.0)
            spring = self.buttonStyleSprings[springId]
        end
        return spring
    end

    function NumberSubPanel:_updateStyleSprings()
        for _, spring in ipairs(self.buttonStyleSprings) do
            spring:moveSpring(vhfHelperLoop:getDt())
        end
    end

    function NumberSubPanel:_pushColorsForButton(id, enabled)
        local spring = self:_getButtonStyleSpring(id)
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

        imgui.PushStyleColor(imgui.constant.Col.Text, textColor)
        imgui.PushStyleColor(imgui.constant.Col.Button, buttonColor)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, buttonActiveColor)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, buttonHoveredColor)
    end

    function NumberSubPanel:_popButtonColors()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end

    function NumberSubPanel:_createNumberButtonAndReactToClicks(number)
        local numberCharacter = self.inputPanelValidator:getValidNumberCharacterOrNil(self.enteredValue, number)
        local enabled = true

        self:_pushColorsForButton(number, numberCharacter ~= nil)

        if
            (imgui.Button(tostring(number), Globals.defaultDummySize, Globals.defaultDummySize) and
                numberCharacter ~= nil)
         then
            self:addCharacter(numberCharacter)
        end

        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end
end

return NumberSubPanel
