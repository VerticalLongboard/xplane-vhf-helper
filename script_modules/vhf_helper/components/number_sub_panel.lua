local Globals = require("vhf_helper.globals")
local Validation = require("vhf_helper.validation")

local NumberSubPanelClass
do
    NumberSubPanel = {}

    function NumberSubPanel:new(newValidator)
        local newInstanceWithState = {
            enteredValue = Globals.emptyString,
            inputPanelValidator = newValidator,
            Constants = {
                ClearButtonTitle = "Clr",
                BackspaceButtonTitle = "Del"
            }
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

    function NumberSubPanel:_renderNumberPanel()
        local numberFontScale = 1.3 * globalFontScale
        imgui.SetWindowFontScale(numberFontScale)

        imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)

        local leftSideDummyScale = 0.3 * globalFontScale
        local rightSideDummyScale = 0.1 * globalFontScale

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(1, 3)

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        imgui.SetWindowFontScale(1.0 * globalFontScale)
        if (imgui.Button(self.Constants.BackspaceButtonTitle)) then
            self:backspace()
        end
        imgui.SetWindowFontScale(numberFontScale)

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(4, 6)

        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize * rightSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        imgui.SetWindowFontScale(1.0 * globalFontScale)
        if (imgui.Button(self.Constants.ClearButtonTitle)) then
            self:clear()
        end
        imgui.SetWindowFontScale(numberFontScale)

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)

        self:_renderNumberButtonsInSameLine(7, 9)

        imgui.Dummy(Globals.defaultDummySize * leftSideDummyScale, Globals.defaultDummySize)
        imgui.SameLine()
        imgui.Dummy(Globals.defaultDummySize, Globals.defaultDummySize)
        imgui.SameLine()

        self:_createNumberButtonAndReactToClicks(0)

        imgui.PopStyleColor()
    end

    function NumberSubPanel:_createNumberButtonAndReactToClicks(number)
        local numberCharacter = self.inputPanelValidator:getValidNumberCharacterOrUnderscore(self.enteredValue, number)

        if
            (imgui.Button(numberCharacter, Globals.defaultDummySize, Globals.defaultDummySize) and
                numberCharacter ~= Globals.underscoreCharacter)
         then
            self:addCharacter(numberCharacter)
        end
    end
end
