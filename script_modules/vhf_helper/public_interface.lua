local Panels = require("vhf_helper.state.panels")
local Datarefs = require("vhf_helper.state.datarefs")
local Validation = require("vhf_helper.state.validation")
local Globals = require("vhf_helper.globals")
local Panels = require("vhf_helper.state.panels")

local EventBus = require("eventbus")

VHFHelperEventOnFrequencyChanged = "EventBus_EventName_VHFHelperEventOnFrequencyChanged"

local function activatePublicInterface()
    VHFHelperPublicInterface = {
        getInterfaceVersion = function()
            return 2
        end,
        enterFrequencyProgrammaticallyAsString = function(atLeastThreeDigitsDecimalOneDigit)
            local newFullString =
                Validation.comFrequencyValidator:validate(
                Validation.comFrequencyValidator:autocomplete(atLeastThreeDigitsDecimalOneDigit)
            )

            local nextVhfFrequency = nil
            if (newFullString ~= nil) then
                nextVhfFrequency = newFullString
            else
                nextVhfFrequency = Globals.emptyString
            end

            Panels.comFrequencyPanel:overrideEnteredValue(nextVhfFrequency)
            return nextVhfFrequency
        end,
        isCurrentlyTunedIn = function(atLeastThreeDigitsDecimalOneDigit)
            local newFullString =
                Validation.comFrequencyValidator:validate(
                Validation.comFrequencyValidator:autocomplete(atLeastThreeDigitsDecimalOneDigit)
            )

            if (newFullString == nil) then
                return false
            end

            for c = 1, 2 do
                currentComString = tostring(Datarefs.comLinkedDatarefs[c]:getLinkedValue())
                currentComString = currentComString:sub(1, 3) .. Globals.decimalCharacter .. currentComString:sub(4, 7)
                if (newFullString == currentComString) then
                    return true
                end
            end

            return false
        end,
        isCurrentlyEntered = function(atLeastThreeDigitsDecimalOneDigit)
            local newFullString =
                Validation.comFrequencyValidator:validate(
                Validation.comFrequencyValidator:autocomplete(atLeastThreeDigitsDecimalOneDigit)
            )

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
        isValidFrequency = function(atLeastThreeDigitsDecimalOneDigit)
            if
                (Validation.comFrequencyValidator:validate(
                    Validation.comFrequencyValidator:autocomplete(atLeastThreeDigitsDecimalOneDigit)
                ) == nil)
             then
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
M.bootstrap = function()
    VHFHelperPublicInterface = nil
    VHFHelperEventBus = EventBus.new()
end
return M
