-- THIS IS AN AUTO-GENERATED PACKED SCRIPT FILE, HERE'S A MEDIUM-LENGTH PSEUDO-RANDOM CONSTANT HEXADECIMAL NUMBER: 647462084eccd274c38ddda9b18eeb5e
require = function(scriptName)
    if (scriptName == "vhf_helper.components.transponder_code_sub_panel") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.transponder_code_sub_panel
        local Globals = require("vhf_helper.globals")
        local Datarefs = require("vhf_helper.datarefs")

        local TransponderCodeSubPanelClass
        do
            TransponderCodeSubPanel = NumberSubPanel:new()

            Globals.OVERRIDE(TransponderCodeSubPanel.new)
            function TransponderCodeSubPanel:new(
                newValidator,
                transponderCodeLinkedDataref,
                transponderModeLinkedDataref,
                newDescriptor)
                local newInstanceWithState = NumberSubPanel:new(newValidator)

                newInstanceWithState.Constants.FullyPaddedString = "----"

                newInstanceWithState.codeDataref = transponderCodeLinkedDataref
                newInstanceWithState.modeDataref = transponderModeLinkedDataref
                newInstanceWithState.descriptor = newDescriptor

                setmetatable(newInstanceWithState, self)
                self.__index = self
                return newInstanceWithState
            end

            Globals.OVERRIDE(TransponderCodeSubPanel.addCharacter)
            function TransponderCodeSubPanel:addCharacter(character)
                if (self.enteredValue:len() == 4) then
                    return
                end

                self.enteredValue = self.enteredValue .. character
            end

            Globals.OVERRIDE(TransponderCodeSubPanel.numberCanBeSetNow)
            function TransponderCodeSubPanel:numberCanBeSetNow()
                return (self.enteredValue:len() > 0)
            end

            Globals._NEWFUNC(TransponderCodeSubPanel._setLinkedValue)
            function TransponderCodeSubPanel:_setLinkedValue()
                local number = tonumber(self.inputPanelValidator:autocomplete(self.enteredValue))
                self.codeDataref:emitNewValue(number)
                self.enteredValue = Globals.emptyString
            end

            Globals._NEWFUNC(TransponderCodeSubPanel._getCurrentLinkedValueString)
            function TransponderCodeSubPanel:_getCurrentLinkedValueString()
                local str = tostring(self.codeDataref:getLinkedValue())
                for i = str:len(), 3 do
                    str = "0" .. str
                end
                return str
            end

            Globals._NEWFUNC(TransponderCodeSubPanel._buildModeButtonLine)
            function TransponderCodeSubPanel:_buildModeButtonLine()
                imgui.SetWindowFontScale(0.8 * globalFontScale)
                imgui.Dummy(8.0, 0.0)
                imgui.SameLine()
                imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 4.0, 0.0)
                imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

                for m = 0, #Datarefs.transponderModeToDescriptor - 1 do
                    self:_renderOneModeButton(m)
                    imgui.SameLine()
                end

                imgui.PopStyleVar()
                imgui.PopStyleVar()
            end

            Globals._NEWFUNC(TransponderCodeSubPanel._renderOneModeButton)
            function TransponderCodeSubPanel:_renderOneModeButton(mode)
                imguiUtils:renderActiveInactiveButton(
                    Datarefs.transponderModeToDescriptor[mode + 1],
                    self.modeDataref:getLinkedValue() == mode,
                    function()
                        self.modeDataref:emitNewValue(mode)
                    end
                )
            end

            Globals._NEWFUNC(TransponderCodeSubPanel._buildCurrentTransponderLine)
            function TransponderCodeSubPanel:_buildCurrentTransponderLine(nextTransponderCodeIsSettable)
                imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

                imgui.TextUnformatted(self.descriptor .. ":    ")

                imgui.SameLine()
                imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)

                local currentTransponderString = self:_getCurrentLinkedValueString()
                imgui.TextUnformatted(currentTransponderString)
                imgui.PopStyleColor()

                imgui.PushStyleColor(imgui.constant.Col.Button, Globals.Colors.a320Green)

                if (nextTransponderCodeIsSettable) then
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.black)
                else
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.white)
                end

                imgui.SameLine()
                imgui.TextUnformatted(" ")

                local buttonText = "   "
                if (nextTransponderCodeIsSettable) then
                    buttonText = "<X>"

                    imgui.SameLine()
                    if (imgui.Button(buttonText)) then
                        self:_setLinkedValue()
                    end
                end

                imgui.PopStyleColor()
                imgui.PopStyleColor()

                imgui.PopStyleVar()
            end

            Globals.OVERRIDE(TransponderCodeSubPanel.renderToCanvas)
            function TransponderCodeSubPanel:renderToCanvas()
                imgui.SetWindowFontScale(1.0 * globalFontScale)

                local nextTransponderCodeIsSettable = self:numberCanBeSetNow()

                imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)

                self:_buildCurrentTransponderLine(nextTransponderCodeIsSettable)
                self:_buildModeButtonLine()

                imgui.SetWindowFontScale(1.0 * globalFontScale)
                imgui.TextUnformatted(" ")
                imgui.Separator()

                imgui.SetWindowFontScale(1.0 * globalFontScale)

                imgui.TextUnformatted("Next " .. self.descriptor .. ":   ")

                if (nextTransponderCodeIsSettable) then
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
                else
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
                end

                imgui.SameLine()

                local paddedString =
                    self.enteredValue .. self.Constants.FullyPaddedString:sub(string.len(self.enteredValue) + 1, 4)
                imgui.TextUnformatted(paddedString)

                imgui.PopStyleVar()

                imgui.PopStyleColor()

                imgui.Separator()
                self:_renderNumberPanel()
            end
        end
    -- END PACKED SCRIPT vhf_helper.components.transponder_code_sub_panel
    end
    if (scriptName == "vhf_helper.validation") then
        -- BEGIN PACKED SCRIPT vhf_helper.validation
        local Globals = require("vhf_helper.globals")

        local NumberValidatorClass
        do
            NumberValidator = {}

            function NumberValidator:new()
                local newInstanceWithState = {}

                setmetatable(newInstanceWithState, self)
                self.__index = self
                return newInstanceWithState
            end

            function NumberValidator:validate(fullString)
                assert(nil)
            end

            function NumberValidator:autocomplete(partialString)
                assert(nil)
            end

            function NumberValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
                assert(nil)
            end
        end

        local TransponderValidatorClass
        do
            TransponderValidator = NumberValidator:new()

            Globals.OVERRIDE(TransponderValidator.new)
            function TransponderValidator:new()
                local newInstanceWithState = NumberValidator:new()
                newInstanceWithState.Constants = {
                    MaxTransponderCode = 7777
                }
                setmetatable(newInstanceWithState, self)
                self.__index = self
                return newInstanceWithState
            end

            Globals.OVERRIDE(TransponderValidator.validate)
            function TransponderValidator:validate(fullString)
                if (fullString == nil) then
                    return nil
                end

                if (fullString:len() ~= 4) then
                    return nil
                end

                local number = tonumber(fullString)
                if (number < 0 or number > self.Constants.MaxTransponderCode) then
                    return nil
                end

                for i = 1, #fullString do
                    if (tonumber(fullString:sub(i, i)) > 7) then
                        return nil
                    end
                end

                return fullString
            end

            Globals.OVERRIDE(TransponderValidator.autocomplete)
            function TransponderValidator:autocomplete(partialString)
                for i = partialString:len(), 3 do
                    partialString = partialString .. "0"
                end

                return partialString
            end

            Globals.OVERRIDE(TransponderValidator.getValidNumberCharacterOrUnderscore)
            function TransponderValidator:getValidNumberCharacterOrUnderscore(stringEnteredSoFar, number)
                local numberAsString = tostring(number)
                local afterEnteringNumber = stringEnteredSoFar .. numberAsString
                local autocompleted = self:autocomplete(afterEnteringNumber)
                if (self:validate(autocompleted) == nil) then
                    return Globals.underscoreCharacter
                end

                return numberAsString
            end
        end

        local FrequencyValidatorClass
        do
            FrequencyValidator = NumberValidator:new()

            Globals._NEWFUNC(FrequencyValidator._checkBasicValidity)
            function FrequencyValidator:_checkBasicValidity(fullFrequencyString, minVhf, maxVhf)
                if (fullFrequencyString == nil) then
                    return nil
                end
                if (fullFrequencyString:len() ~= 7) then
                    return nil
                end
                if (fullFrequencyString:sub(4, 4) ~= Globals.decimalCharacter) then
                    return nil
                end

                local cleanFrequencyString = fullFrequencyString:sub(1, 3) .. fullFrequencyString:sub(5, 7)

                frequencyNumber = tonumber(cleanFrequencyString)
                if (frequencyNumber < minVhf or frequencyNumber > maxVhf) then
                    return nil
                end

                return cleanFrequencyString
            end
        end

        local COMFrequencyValidatorClass
        do
            COMFrequencyValidator = FrequencyValidator:new()

            Globals.OVERRIDE(COMFrequencyValidator.validate)
            function COMFrequencyValidator:validate(fullFrequencyString)
                local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 118000, 136975)
                if (cleanFrequencyString == nil) then
                    return nil
                end

                minorOneDigit = cleanFrequencyString:sub(6, 6)
                minorTenDigit = cleanFrequencyString:sub(5, 5)
                if (minorOneDigit ~= "0" and minorOneDigit ~= "5") then
                    minorOneDigit = "0"
                    cleanFrequencyString = replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
                end

                if (minorTenDigit == "2" or minorTenDigit == "7") then
                    minorOneDigit = "5"
                    cleanFrequencyString = Globals.replaceCharacter(cleanFrequencyString, 6, minorOneDigit)
                end

                return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
            end

            Globals.OVERRIDE(COMFrequencyValidator.autocomplete)
            function COMFrequencyValidator:autocomplete(partialFrequencyString)
                local nextStringLength = partialFrequencyString:len()
                if (nextStringLength == 5) then
                    partialFrequencyString = partialFrequencyString .. "00"
                elseif (nextStringLength == 6) then
                    minorTenDigit = partialFrequencyString:sub(6, 6)
                    if (minorTenDigit == "2" or minorTenDigit == "7") then
                        partialFrequencyString = partialFrequencyString .. "5"
                    else
                        partialFrequencyString = partialFrequencyString .. "0"
                    end
                end

                return partialFrequencyString
            end

            Globals.OVERRIDE(COMFrequencyValidator.getValidNumberCharacterOrUnderscore)
            function COMFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
                if (string.len(frequencyEnteredSoFar) == 7) then
                    return Globals.underscoreCharacter
                end

                local character = tostring(number)
                freqStringLength = string.len(frequencyEnteredSoFar)

                if (freqStringLength == 0) then
                    if (number ~= 1) then
                        character = Globals.underscoreCharacter
                    end
                elseif (freqStringLength == 1) then
                    if (number < 1 or number > 3) then
                        character = Globals.underscoreCharacter
                    end
                elseif (freqStringLength == 2) then
                    majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
                    if (majorTenDigit == "1") then
                        if (number < 8) then
                            character = Globals.underscoreCharacter
                        end
                    elseif (majorTenDigit == "3") then
                        if (number > 6) then
                            character = Globals.underscoreCharacter
                        end
                    end
                elseif (freqStringLength == 5) then
                    minorHundredDigit = frequencyEnteredSoFar:sub(5, 5)
                    if (minorHundredDigit == "9") then
                        if (number > 7) then
                            character = Globals.underscoreCharacter
                        end
                    end
                elseif (freqStringLength == 6) then
                    if (number ~= 0 and number ~= 5) then
                        character = Globals.underscoreCharacter
                    end

                    minorTenDigit = frequencyEnteredSoFar:sub(6, 6)

                    if ((minorTenDigit == "2" or minorTenDigit == "7") and number == 0) then
                        character = Globals.underscoreCharacter
                    elseif ((minorTenDigit == "4" or minorTenDigit == "9") and number == 5) then
                        character = Globals.underscoreCharacter
                    end
                end

                return character
            end
        end

        local NAVFrequencyValidatorClass
        do
            NAVFrequencyValidator = FrequencyValidator:new()

            Globals.OVERRIDE(NAVFrequencyValidator.validate)
            function NAVFrequencyValidator:validate(fullFrequencyString)
                local cleanFrequencyString = self:_checkBasicValidity(fullFrequencyString, 108000, 117950)
                if (cleanFrequencyString == nil) then
                    return nil
                end

                minorTenDigit = cleanFrequencyString:sub(5, 5)
                if (minorTenDigit ~= "0" and minorTenDigit ~= "5") then
                    return nil
                end

                minorOneDigit = cleanFrequencyString:sub(6, 6)
                if (minorOneDigit ~= "0") then
                    return nil
                end

                return cleanFrequencyString:sub(1, 3) .. Globals.decimalCharacter .. cleanFrequencyString:sub(4, 7)
            end

            Globals.OVERRIDE(NAVFrequencyValidator.autocomplete)
            function NAVFrequencyValidator:autocomplete(partialFrequencyString)
                local nextStringLength = partialFrequencyString:len()
                if (nextStringLength == 5) then
                    partialFrequencyString = partialFrequencyString .. "00"
                elseif (nextStringLength == 6) then
                    partialFrequencyString = partialFrequencyString .. "0"
                end

                return partialFrequencyString
            end

            Globals.OVERRIDE(NAVFrequencyValidator.getValidNumberCharacterOrUnderscore)
            function NAVFrequencyValidator:getValidNumberCharacterOrUnderscore(frequencyEnteredSoFar, number)
                if (string.len(frequencyEnteredSoFar) == 7) then
                    return Globals.underscoreCharacter
                end

                local character = tostring(number)
                freqStringLength = string.len(frequencyEnteredSoFar)

                if (freqStringLength == 0) then
                    if (number ~= 1) then
                        character = Globals.underscoreCharacter
                    end
                elseif (freqStringLength == 1) then
                    if (number > 1) then
                        character = Globals.underscoreCharacter
                    end
                elseif (freqStringLength == 2) then
                    majorTenDigit = frequencyEnteredSoFar:sub(2, 2)
                    if (majorTenDigit == "0") then
                        if (number < 8) then
                            character = Globals.underscoreCharacter
                        end
                    elseif (majorTenDigit == "1") then
                        if (number > 7) then
                            character = Globals.underscoreCharacter
                        end
                    end
                elseif (freqStringLength == 5) then
                    if (number ~= 0 and number ~= 5) then
                        character = Globals.underscoreCharacter
                    end
                elseif (freqStringLength == 6) then
                    if (number ~= 0) then
                        character = Globals.underscoreCharacter
                    end
                end

                return character
            end
        end

        local M = {}
        M.bootstrap = function()
            M.transponderCodeValidator = TransponderValidator:new()
            M.comFrequencyValidator = COMFrequencyValidator:new()
            M.navFrequencyValidator = NAVFrequencyValidator:new()
        end
        return M
    -- END PACKED SCRIPT vhf_helper.validation
    end
    if (scriptName == "vhf_helper.components.com_frequency_sub_panel") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.com_frequency_sub_panel
        local Globals = require("vhf_helper.globals")
        require("vhf_helper.components.vhf_frequency_sub_panel")

        local ComFrequencySubPanelClass
        do
            ComFrequencySubPanel = VhfFrequencySubPanel:new()

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
        end
    -- END PACKED SCRIPT vhf_helper.components.com_frequency_sub_panel
    end
    if (scriptName == "vhf_helper.components.number_sub_panel") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.number_sub_panel
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
                local numberCharacter =
                    self.inputPanelValidator:getValidNumberCharacterOrUnderscore(self.enteredValue, number)

                if
                    (imgui.Button(numberCharacter, Globals.defaultDummySize, Globals.defaultDummySize) and
                        numberCharacter ~= Globals.underscoreCharacter)
                 then
                    self:addCharacter(numberCharacter)
                end
            end
        end
    -- END PACKED SCRIPT vhf_helper.components.number_sub_panel
    end
    if (scriptName == "vhf_helper.loop") then
        -- BEGIN PACKED SCRIPT vhf_helper.loop
        local Configuration = require("vhf_helper.configuration")
        local Globals = require("vhf_helper.globals")
        local Datarefs = require("vhf_helper.datarefs")

        local vhfHelperLoopSingleton
        do
            vhfHelperLoop = {}

            function vhfHelperLoop:isInitialized()
                return self.alreadyInitialized
            end

            function vhfHelperLoop:_reset()
                self.Constants = {
                    defaultMacroName = Globals.readableScriptName
                }
                self.alreadyInitialized = false
            end

            function vhfHelperLoop:bootstrap()
                self:_reset()
                Configuration.Config:load()

                local windowIsSupposedToBeVisible = false
                if
                    (Globals.trim(
                        Configuration.Config:getValue("Windows", "MainWindowVisibility", Globals.windowVisibilityHidden)
                    ) == Globals.windowVisibilityVisible)
                 then
                    windowIsSupposedToBeVisible = true
                end

                add_macro(
                    self.Constants.defaultMacroName,
                    "vhfHelperMainWindow:create()",
                    "vhfHelperMainWindow:destroy()",
                    Globals.windowVisibilityToInitialMacroState(windowIsSupposedToBeVisible)
                )

                create_command(
                    "FlyWithLua/" .. Globals.readableScriptName .. "/TogglePanel",
                    "Toggle " .. Globals.readableScriptName .. " Window",
                    "vhfHelperMainWindow:toggle()",
                    "",
                    ""
                )

                do_often("vhfHelperLoop:tryInitializeOften()")
            end

            function vhfHelperLoop:tryInitializeOften()
                if (self.alreadyInitialized) then
                    return
                end

                if (not self:_canInitializeNow()) then
                    return
                end

                self:_initializeNow()
                self.alreadyInitialized = true

                do_every_frame("vhfHelperLoop:everyFrameLoop()")
            end

            function vhfHelperLoop:everyFrameLoop()
                if (not self.alreadyInitialized) then
                    return
                end

                for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
                    ldr:loopUpdate()
                end
            end

            function vhfHelperLoop:_canInitializeNow()
                for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
                    if (not ldr:isLocalLinkedDatarefAvailable()) then
                        return false
                    end
                end

                return true
            end

            function vhfHelperLoop:_initializeNow()
                for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
                    ldr:initialize()
                end
            end
        end
    -- END PACKED SCRIPT vhf_helper.loop
    end
    if (scriptName == "vhf_helper.datarefs") then
        -- BEGIN PACKED SCRIPT vhf_helper.datarefs
        local Validation = require("vhf_helper.validation")
        local Globals = require("vhf_helper.globals")

        -- FlyWithLua Issue: Pre-defined dataref handles cannot be in a table :-/
        InterchangeCOM1Frequency = 0
        InterchangeCOM2Frequency = 0
        InterchangeNAV1Frequency = 0
        InterchangeNAV2Frequency = 0
        InterchangeTransponderCode = 0
        InterchangeTransponderMode = 0

        COM1FrequencyRead = 0
        COM2FrequencyRead = 0
        NAV1FrequencyRead = 0
        NAV2FrequencyRead = 0
        TransponderCodeRead = 0
        TransponderModeRead = 0

        local function isFrequencyValueValid(ild, validator, newValue)
            -- FlyWithLua Issue:
            -- After creating a shared new dataref (and setting its inital value) the writable dataref variable is being assigned a
            -- random value (very likely straight from memory) after waiting a few frames.
            -- To workaround, ignore invalid values and continue using local COM frequency values (which are supposed to be valid at this time).
            local freqString = tostring(newValue)
            local freqFullString = freqString:sub(1, 3) .. Globals.decimalCharacter .. freqString:sub(4, 6)
            if (not validator:validate(freqFullString)) then
                Globals.printLogMessage(
                    ("Warning: Interchange variable %s has been externally assigned an invalid value=%s. " ..
                        "This is very likely happening during initialization and is a known issue in FlyWithLua/X-Plane dataref handling. " ..
                            "If this happens during flight, something is seriously wrong."):format(
                        ild.interchangeDatarefName,
                        freqFullString
                    )
                )
                return false
            end

            return true
        end

        local onNotRequiredCallbackFunction = function(ild, newValue)
        end

        local onComLinkedChanged = function(ild, newLinkedValue)
            VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
        end

        local isNewComFrequencyValid = function(ild, newValue)
            return isFrequencyValueValid(ild, Validation.comFrequencyValidator, newValue)
        end

        local isNewNavFrequencyValid = function(ild, newValue)
            return isFrequencyValueValid(ild, Validation.navFrequencyValidator, newValue)
        end

        local isNewTransponderCodeValid = function(ild, newValue)
            if (newValue < 0 or newValue > Validation.transponderCodeValidator.Constants.MaxTransponderCode) then
                return false
            end
        end

        local transponderModeToDescriptor = {}

        table.insert(transponderModeToDescriptor, "OFF")
        table.insert(transponderModeToDescriptor, "STBY")
        table.insert(transponderModeToDescriptor, "ON")
        table.insert(transponderModeToDescriptor, "ALT2")
        table.insert(transponderModeToDescriptor, "ALT3")

        local isNewTransponderModeValid = function(ild, newValue)
            -- This is based on personal observation in different airplanes:
            -- 0: OFF
            -- 1: STBY <<
            -- 2: ON/XPDR <<
            -- 3: TEST/XPDR/ALT <<
            -- 4: TEST2/XPDR
            --
            -- There's too much confusion, I can't get no relief:
            -- https://forums.x-plane.org/index.php?/forums/topic/85093-transponder_mode-datarefs-altitude-reporting-and-confusion/
            if (newValue < 0 or newValue > 4) then
                printLogMessage(
                    ("Invalid transponder code=%s received. Will not update local transponder mode."):format(
                        tostring(newValue)
                    )
                )
                return false
            end

            return true
        end

        local M = {}
        M.transponderModeToDescriptor = transponderModeToDescriptor
        M.bootstrap = function()
            M.COMLinkedDatarefs = {
                InterchangeLinkedDataref:new(
                    InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                    "VHFHelper/InterchangeCOM1Frequency",
                    "InterchangeCOM1Frequency",
                    "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
                    "COM1FrequencyRead",
                    onNotRequiredCallbackFunction,
                    onComLinkedChanged,
                    isNewComFrequencyValid
                ),
                InterchangeLinkedDataref:new(
                    InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                    "VHFHelper/InterchangeCOM2Frequency",
                    "InterchangeCOM2Frequency",
                    "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
                    "COM2FrequencyRead",
                    onNotRequiredCallbackFunction,
                    onComLinkedChanged,
                    isNewComFrequencyValid
                )
            }
            M.NAVLinkedDatarefs = {
                InterchangeLinkedDataref:new(
                    InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                    "VHFHelper/InterchangeNAV1Frequency",
                    "InterchangeNAV1Frequency",
                    "sim/cockpit2/radios/actuators/nav1_frequency_hz",
                    "NAV1FrequencyRead",
                    onNotRequiredCallbackFunction,
                    onNotRequiredCallbackFunction,
                    isNewNavFrequencyValid
                ),
                InterchangeLinkedDataref:new(
                    InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                    "VHFHelper/InterchangeNAV2Frequency",
                    "InterchangeNAV2Frequency",
                    "sim/cockpit2/radios/actuators/nav2_frequency_hz",
                    "NAV2FrequencyRead",
                    onNotRequiredCallbackFunction,
                    onNotRequiredCallbackFunction,
                    isNewNavFrequencyValid
                )
            }
            M.TransponderModeLinkedDataref =
                InterchangeLinkedDataref:new(
                InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                "VHFHelper/InterchangeTransponderMode",
                "InterchangeTransponderMode",
                "sim/cockpit2/radios/actuators/transponder_mode",
                "TransponderModeRead",
                onNotRequiredCallbackFunction,
                onNotRequiredCallbackFunction,
                isNewTransponderModeValid
            )
            M.TransponderCodeLinkedDataref =
                InterchangeLinkedDataref:new(
                InterchangeLinkedDataref.Constants.DatarefTypeInteger,
                "VHFHelper/InterchangeTransponderCode",
                "InterchangeTransponderCode",
                "sim/cockpit2/radios/actuators/transponder_code",
                "TransponderCodeRead",
                onNotRequiredCallbackFunction,
                onNotRequiredCallbackFunction,
                isNewTransponderCodeValid
            )
            M.allLinkedDatarefs = {
                M.COMLinkedDatarefs[1],
                M.COMLinkedDatarefs[2],
                M.NAVLinkedDatarefs[1],
                M.NAVLinkedDatarefs[2],
                M.TransponderCodeLinkedDataref,
                M.TransponderModeLinkedDataref
            }
        end
        return M
    -- END PACKED SCRIPT vhf_helper.datarefs
    end
    if (scriptName == "vhf_helper.public_interface") then
        -- BEGIN PACKED SCRIPT vhf_helper.public_interface
        local Panels = require("vhf_helper.panels")
        local Datarefs = require("vhf_helper.datarefs")
        local Validation = require("vhf_helper.validation")
        local Globals = require("vhf_helper.globals")
        local Panels = require("vhf_helper.panels")

        VHFHelperPublicInterface = nil
        local EventBus = require("eventbus")
        VHFHelperEventBus = EventBus.new()
        VHFHelperEventOnFrequencyChanged = "EventBus_EventName_VHFHelperEventOnFrequencyChanged"

        local function activatePublicInterface()
            VHFHelperPublicInterface = {
                getInterfaceVersion = function()
                    return 1
                end,
                enterFrequencyProgrammaticallyAsString = function(newFullString)
                    newFullString = Validation.comFrequencyValidator:validate(newFullString)

                    local nextVhfFrequency = nil
                    if (newFullString ~= nil) then
                        nextVhfFrequency = newFullString
                    else
                        nextVhfFrequency = Globals.emptyString
                    end

                    Panels.comFrequencyPanel:overrideEnteredValue(nextVhfFrequency)
                    return nextVhfFrequency
                end,
                isCurrentlyTunedIn = function(fullFrequencyString)
                    newFullString = Validation.comFrequencyValidator:validate(fullFrequencyString)
                    if (newFullString == nil) then
                        return false
                    end

                    for c = 1, 2 do
                        currentComString = tostring(Datarefs.COMLinkedDatarefs[c]:getLinkedValue())
                        currentComString =
                            currentComString:sub(1, 3) .. Globals.decimalCharacter .. currentComString:sub(4, 7)
                        if (newFullString == currentComString) then
                            return true
                        end
                    end

                    return false
                end,
                isCurrentlyEntered = function(fullFrequencyString)
                    newFullString = Validation.comFrequencyValidator:validate(fullFrequencyString)
                    if (newFullString == nil) then
                        return false
                    end

                    autocompletedNextVhf =
                        Validation.comFrequencyValidator:autocomplete(Panels.comFrequencyPanel:getEnteredValue())

                    if (newFullString == autocompletedNextVhf) then
                        return true
                    end

                    return false
                end,
                isValidFrequency = function(fullFrequencyString)
                    if (Validation.comFrequencyValidator:validate(fullFrequencyString) == nil) then
                        return false
                    else
                        return true
                    end
                end
            }
        end

        local function deactivatePublicInterface()
            VHFHelperPublicInterface = nil
        end

        local M = {}
        M.activatePublicInterface = activatePublicInterface
        M.deactivatePublicInterface = deactivatePublicInterface
        return M
    -- END PACKED SCRIPT vhf_helper.public_interface
    end
    if (scriptName == "vhf_helper.main_window") then
        -- BEGIN PACKED SCRIPT vhf_helper.main_window
        local Configuration = require("vhf_helper.configuration")
        local PublicInterface = require("vhf_helper.public_interface")
        local Panels = require("vhf_helper.panels")
        local Globals = require("vhf_helper.globals")

        -- FlyWithLua Issue: Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/
        function renderVhfHelperMainWindowToCanvas()
            vhfHelperMainWindow:renderToCanvas()
        end

        function closeVhfHelperMainWindow()
            -- FlyWithLua Issue: The close function is called asynchronously so quickly closing and opening the panel will close it again quickly after.
            -- Destroy it anyway to keep public interface in line with panel visibility.
            vhfHelperMainWindow:destroy()
        end

        local vhfHelperMainWindowSingleton
        do
            vhfHelperMainWindow = {}

            function vhfHelperMainWindow:_reset()
                self.Constants = {defaultWindowName = Globals.readableScriptName}
                self.window = nil
                self.currentPanel = Panels.comFrequencyPanel
            end

            function vhfHelperMainWindow:bootstrap()
                self:_reset()
            end

            function vhfHelperMainWindow:create()
                vhfHelperLoop:tryInitializeOften()

                if (self.window ~= nil) then
                    return
                end

                local minWidthWithoutScrollbars = nil
                local minHeightWithoutScrollbars = nil

                globalFontScaleDescriptor =
                    Globals.trim(Configuration.Config:getValue("Windows", "GlobalFontScale", "big"))
                if (globalFontScaleDescriptor == "huge") then
                    globalFontScale = 3.0
                    minWidthWithoutScrollbars = 380
                    minHeightWithoutScrollbars = 460
                elseif (globalFontScaleDescriptor == "big") then
                    globalFontScale = 2.0
                    minWidthWithoutScrollbars = 260
                    minHeightWithoutScrollbars = 320
                else
                    globalFontScale = 1.0
                    minWidthWithoutScrollbars = 150
                    minHeightWithoutScrollbars = 190
                end

                Globals.defaultDummySize = 20.0 * globalFontScale

                self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
                float_wnd_set_title(self.window, self.Constants.defaultWindowName)
                float_wnd_set_imgui_builder(self.window, "renderVhfHelperMainWindowToCanvas")
                float_wnd_set_onclose(self.window, "closeVhfHelperMainWindow")

                Configuration.Config:setValue("Windows", "MainWindowVisibility", Globals.windowVisibilityVisible)
                Configuration.Config:save()

                PublicInterface.activatePublicInterface()
            end

            function vhfHelperMainWindow:destroy()
                if (self.window == nil) then
                    return
                end

                float_wnd_destroy(self.window)
                self.window = nil

                Configuration.Config:setValue("Windows", "MainWindowVisibility", Globals.windowVisibilityHidden)
                Configuration.Config:save()

                PublicInterface.deactivatePublicInterface()
            end

            function vhfHelperMainWindow:show(value)
                -- FlyWithLua Issue: Using float_wnd_set_visible only works for _hiding_ the panel, not for making it visible again.
                -- Create and destroy for now.
                if (self.window == nil and value) then
                    self:create()
                elseif (self.window ~= nil and not value) then
                    self:destroy()
                end
            end

            function vhfHelperMainWindow:toggle()
                self:show(self.window == nil)
            end

            function vhfHelperMainWindow:renderToCanvas()
                local slightlyBrighterDefaultButtonColor = 0xFF7F5634
                imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Globals.Colors.defaultImguiButtonBackground)
                imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, slightlyBrighterDefaultButtonColor)

                self.currentPanel:renderToCanvas()

                imgui.Separator()
                imgui.Separator()
                imgui.SetWindowFontScale(0.9 * globalFontScale)
                self:_renderPanelButton(Panels.comFrequencyPanel)
                imgui.SameLine()
                self:_renderPanelButton(Panels.navFrequencyPanel)
                imgui.SameLine()
                self:_renderPanelButton(Panels.transponderCodePanel)
                imgui.SameLine()

                imgui.PopStyleColor()
                imgui.PopStyleColor()
            end

            function vhfHelperMainWindow:_renderPanelButton(panel)
                imguiUtils:renderActiveInactiveButton(
                    " " .. panel.descriptor .. " ",
                    self.currentPanel == panel,
                    function()
                        self.currentPanel = panel
                    end
                )
            end
        end
    -- END PACKED SCRIPT vhf_helper.main_window
    end
    if (scriptName == "vhf_helper.components.interchange_linked_dataref") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.interchange_linked_dataref
        local InterchangeLinkedDatarefClass
        do
            InterchangeLinkedDataref = {
                Constants = {
                    DatarefTypeInteger = "Int",
                    DatarefAccessTypeWritable = "writable",
                    DatarefAccessTypeReadable = "readable"
                }
            }
            function InterchangeLinkedDataref:new(
                newDataType,
                newInterchangeDatarefName,
                newInterchangeVariableName,
                newLinkedDatarefName,
                newLinkedReadVariableName,
                newOnInterchangeChangeFunction,
                newOnLinkedChangeFunction,
                newIsNewValueValidFunction)
                local newValue = nil

                local newInstanceWithState = {
                    dataType = newDataType,
                    interchangeDatarefName = newInterchangeDatarefName,
                    interchangeVariableName = newInterchangeVariableName,
                    linkedDatarefName = newLinkedDatarefName,
                    linkedReadVariableName = newLinkedReadVariableName,
                    onInterchangeChangeFunction = newOnInterchangeChangeFunction,
                    onLinkedChangeFunction = newOnLinkedChangeFunction,
                    isNewValueValidFunction = newIsNewValueValidFunction,
                    lastLinkedValue = nil,
                    lastInterchangeValue = nil,
                    linkedDatarefWriteHandle = nil,
                    getInterchangeValueFunction = loadstring("return " .. newInterchangeVariableName),
                    getLinkedValueFunction = loadstring("return " .. newLinkedReadVariableName)
                }

                setmetatable(newInstanceWithState, self)
                self.__index = self
                return newInstanceWithState
            end

            function InterchangeLinkedDataref:initialize()
                define_shared_DataRef(self.interchangeDatarefName, self.dataType)
                dataref(
                    self.interchangeVariableName,
                    self.interchangeDatarefName,
                    self.Constants.DatarefAccessTypeWritable
                )

                dataref(self.linkedReadVariableName, self.linkedDatarefName, self.Constants.DatarefAccessTypeReadable)
                self.linkedDatarefWriteHandle = XPLMFindDataRef(self.linkedDatarefName)

                local linkedValue = self.getLinkedValueFunction()
                self.lastLinkedValue = linkedValue
                self.lastInterchangeValue = linkedValue
                self:_setInterchangeValue(linkedValue)
            end

            function InterchangeLinkedDataref:loopUpdate()
                local currentInterchangeValue = self:getInterchangeValue()
                if (currentInterchangeValue ~= self.lastInterchangeValue) then
                    if (not self.isNewValueValidFunction(self, currentInterchangeValue)) then
                        currentInterchangeValue = self:getLinkedValue()
                        self:_setInterchangeValue(currentInterchangeValue)
                    end

                    self.onInterchangeChangeFunction(self, currentInterchangeValue)
                    self:_setLinkedValue(currentInterchangeValue)
                    self.lastInterchangeValue = currentInterchangeValue
                end

                local currentLinkedValue = self:getLinkedValue()
                if (currentLinkedValue ~= self.lastLinkedValue) then
                    self.onLinkedChangeFunction(self, currentLinkedValue)
                    self.lastLinkedValue = currentLinkedValue
                end
            end

            function InterchangeLinkedDataref:emitNewValue(value)
                self:_setInterchangeValue(value)
                self:_setLinkedValue(value)
            end

            function InterchangeLinkedDataref:getLinkedValue()
                return self.getLinkedValueFunction()
            end

            function InterchangeLinkedDataref:getInterchangeValue()
                return self.getInterchangeValueFunction()
            end

            function InterchangeLinkedDataref:isLocalLinkedDatarefAvailable()
                return XPLMFindDataRef(self.linkedDatarefName)
            end

            function InterchangeLinkedDataref:_setInterchangeValue(value)
                local setInterchangeValueFunction = loadstring(self.interchangeVariableName .. " = " .. value)
                setInterchangeValueFunction()
                self.lastInterchangeValue = value
            end

            function InterchangeLinkedDataref:_setLinkedValue(value)
                XPLMSetDatai(self.linkedDatarefWriteHandle, value)
            end
        end
    -- END PACKED SCRIPT vhf_helper.components.interchange_linked_dataref
    end
    if (scriptName == "vhf_helper.panels") then
        -- BEGIN PACKED SCRIPT vhf_helper.panels
        local Validation = require("vhf_helper.validation")
        local Datarefs = require("vhf_helper.datarefs")
        require("vhf_helper.components.com_frequency_sub_panel")
        require("vhf_helper.components.nav_frequency_sub_panel")
        require("vhf_helper.components.transponder_code_sub_panel")

        local M = {}

        M.bootstrap = function()
            M.comFrequencyPanel =
                ComFrequencySubPanel:new(
                Validation.comFrequencyValidator,
                Datarefs.COMLinkedDatarefs[1],
                Datarefs.COMLinkedDatarefs[2],
                "COM"
            )
            M.navFrequencyPanel =
                NavFrequencySubPanel:new(
                Validation.navFrequencyValidator,
                Datarefs.NAVLinkedDatarefs[1],
                Datarefs.NAVLinkedDatarefs[2],
                "NAV"
            )
            M.transponderCodePanel =
                TransponderCodeSubPanel:new(
                Validation.transponderCodeValidator,
                Datarefs.TransponderCodeLinkedDataref,
                Datarefs.TransponderModeLinkedDataref,
                "XPDR"
            )
        end
        return M
    -- END PACKED SCRIPT vhf_helper.panels
    end
    if (scriptName == "vhf_helper.components.vhf_frequency_sub_panel") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.vhf_frequency_sub_panel
        local Globals = require("vhf_helper.globals")
        require("vhf_helper.components.number_sub_panel")

        local VhfFrequencySubPanelClass
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
                newDescriptor)
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
                imgui.TextUnformatted(
                    currentVhfString:sub(1, 3) .. Globals.decimalCharacter .. currentVhfString:sub(4, 7)
                )
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

                local cleanVhfFrequency = self.inputPanelValidator:autocomplete(self.enteredValue):gsub("%.", "")
                self:_setCleanLinkedValueString(vhfNumber, cleanVhfFrequency)

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
    -- END PACKED SCRIPT vhf_helper.components.vhf_frequency_sub_panel
    end
    if (scriptName == "vhf_helper.components.nav_frequency_sub_panel") then
        -- BEGIN PACKED SCRIPT vhf_helper.components.nav_frequency_sub_panel
        local Globals = require("vhf_helper.globals")

        local NavFrequencySubPanelClass
        do
            NavFrequencySubPanel = VhfFrequencySubPanel:new()

            Globals.OVERRIDE(NavFrequencySubPanel._getCurrentCleanLinkedValueString)
            function NavFrequencySubPanel:_getCurrentCleanLinkedValueString(vhfNumber)
                return tostring(self.linkedDatarefs[vhfNumber]:getLinkedValue()) .. "0"
            end

            Globals.OVERRIDE(NavFrequencySubPanel._setCleanLinkedValueString)
            function NavFrequencySubPanel:_setCleanLinkedValueString(vhfNumber, cleanValueString)
                cleanValueString = cleanValueString:sub(1, 5)
                local nextFrequencyAsNumber = tonumber(cleanValueString)
                self.linkedDatarefs[vhfNumber]:emitNewValue(nextFrequencyAsNumber)
            end
        end
    -- END PACKED SCRIPT vhf_helper.components.nav_frequency_sub_panel
    end
    if (scriptName == "vhf_helper.globals") then
        -- BEGIN PACKED SCRIPT vhf_helper.globals
        local Globals = {
            emptyString = "",
            decimalCharacter = ".",
            underscoreCharacter = "_",
            readableScriptName = "VR Radio Helper"
        }

        Globals.printLogMessage = function(messageString)
            logMsg(("%s: %s"):format(Globals.readableScriptName, messageString or "NIL"))
        end

        local licensesOfDependencies = {
            {
                "Lua INI Parser",
                "MIT License",
                "https://github.com/Dynodzzo/Lua_INI_Parser"
            },
            {
                "Lua Event Bus",
                "MIT License",
                "https://github.com/prabirshrestha/lua-eventbus"
            },
            {"LuaUnit", "BSD License", "https://github.com/bluebird75/luaunit"},
            {"FlyWithLua", "MIT License", "https://github.com/X-Friese/FlyWithLua"}
        }
        for i = 1, #licensesOfDependencies do
            Globals.printLogMessage(
                ("Using '%s' with license '%s'. Project homepage: %s"):format(
                    licensesOfDependencies[i][1],
                    licensesOfDependencies[i][2],
                    licensesOfDependencies[i][3]
                )
            )
        end

        Globals.trim = function(str)
            return str:gsub("^%s*(.-)%s*$", "%1")
        end

        Globals.replaceCharacter = function(str, pos, newCharacter)
            return str:sub(1, pos - 1) .. newCharacter .. str:sub(pos + 1)
        end

        Globals.OVERRIDE = function(overriddenFunction)
            assert(overriddenFunction)
        end

        Globals._NEWFUNC = function(overriddenFunction)
            assert(overriddenFunction == nil)
        end

        Globals.windowVisibilityToInitialMacroState = function(windowIsVisible)
            if windowIsVisible then
                return "activate"
            else
                return "deactivate"
            end
        end

        Globals.windowVisibilityVisible = "visible"
        Globals.windowVisibilityHidden = "hidden"

        Globals.globalFontScale = nil
        Globals.defaultDummySize = nil

        Globals.Colors = {
            a320Orange = 0xFF00AAFF,
            a320Blue = 0xFFFFDDAA,
            a320Green = 0xFF00AA00,
            white = 0xFFFFFFFF,
            black = 0xFF000000,
            defaultImguiBackground = 0xFF121110,
            defaultImguiButtonBackground = 0xFF6F4624
        }

        local imguiUtilsSingleton
        do
            imguiUtils = {}
            function imguiUtils:renderActiveInactiveButton(buttonTitle, active, onPressFunction)
                if (active) then
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
                else
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
                end

                if (imgui.Button(buttonTitle)) then
                    onPressFunction()
                end

                imgui.PopStyleColor()
            end
        end

        return Globals
    -- END PACKED SCRIPT vhf_helper.globals
    end
    if (scriptName == "vhf_helper.configuration") then
        -- BEGIN PACKED SCRIPT vhf_helper.configuration
        local Globals = require("vhf_helper.globals")
        local LuaIniParser = require("LIP")

        local function fileExists(filePath)
            local file = io.open(filePath, "r")
            if file == nil then
                return false
            end

            io.close(file)
            return true
        end

        local ConfigurationClass
        do
            Configuration = {}

            function Configuration:new(iniFilePath)
                local newInstanceWithState = {Path = iniFilePath, Content = {}}
                setmetatable(newInstanceWithState, self)
                self.__index = self
                return newInstanceWithState
            end

            function Configuration:load()
                if (not fileExists(self.Path)) then
                    return
                end

                self.Content = LuaIniParser.load(self.Path)
            end

            function Configuration:save()
                LuaIniParser.save(self.Path, self.Content)
            end

            function Configuration:setValue(section, key, value)
                if (self.Content[section] == nil) then
                    self.Content[section] = {}
                end
                if (type(value) == "string") then
                    value = Globals.trim(value)
                end

                self.Content[section][key] = value
            end

            function Configuration:getValue(section, key, defaultValue)
                if (self.Content[section] == nil) then
                    self.Content[section] = {}
                end
                if (self.Content[section][key]) == nil then
                    self.Content[section][key] = defaultValue
                end

                return self.Content[section][key]
            end
        end

        local Config = nil

        local M = {}
        M.Config = Config
        M.Configuration = Configuration
        M.bootstrap = function()
            Config = Configuration:new(SCRIPT_DIRECTORY .. "vhf_helper.ini")
            M.Config = Config
        end
        return M
    -- END PACKED SCRIPT vhf_helper.configuration
    end
end
--[[

MIT License

Copyright (c) 2020 VerticalLongboard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]
-- do
require = require or require

require("vhf_helper.components.interchange_linked_dataref")
require("vhf_helper.components.number_sub_panel")
require("vhf_helper.components.vhf_frequency_sub_panel")
require("vhf_helper.components.com_frequency_sub_panel")
require("vhf_helper.components.nav_frequency_sub_panel")
require("vhf_helper.components.transponder_code_sub_panel")

local Globals = require("vhf_helper.globals")
local PublicInterface = require("vhf_helper.public_interface")

local Validation = require("vhf_helper.validation")
Validation.bootstrap()
local Datarefs = require("vhf_helper.datarefs")
Datarefs.bootstrap()
local Panels = require("vhf_helper.panels")
Panels.bootstrap()
local Configuration = require("vhf_helper.configuration")
Configuration.bootstrap()

require("vhf_helper.main_window")
vhfHelperMainWindow:bootstrap()

require("vhf_helper.loop")
vhfHelperLoop:bootstrap()

vhfHelperPackageExport = {}
vhfHelperPackageExport.test = {}
vhfHelperPackageExport.test.comFrequencyValidator = Validation.comFrequencyValidator
vhfHelperPackageExport.test.navFrequencyValidator = Validation.navFrequencyValidator
vhfHelperPackageExport.test.transponderCodeValidator = Validation.transponderCodeValidator
vhfHelperPackageExport.test.activatePublicInterface = PublicInterface.activatePublicInterface
vhfHelperPackageExport.test.deactivatePublicInterface = PublicInterface.deactivatePublicInterface
vhfHelperPackageExport.test.Config = Configuration.Config
vhfHelperPackageExport.test.vhfHelperLoop = vhfHelperLoop
vhfHelperPackageExport.test.vhfHelperMainWindow = vhfHelperMainWindow
vhfHelperPackageExport.test.COMLinkedDatarefs = Datarefs.COMLinkedDatarefs
vhfHelperPackageExport.test.NAVLinkedDatarefs = Datarefs.NAVLinkedDatarefs
vhfHelperPackageExport.test.transponderModeToDescriptor = Datarefs.transponderModeToDescriptor

-- FlyWithLua Issue: When returning anything besides nothing, FlyWithLua does not expose global fields to other scripts
return