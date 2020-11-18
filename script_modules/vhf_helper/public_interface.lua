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
                currentComString = currentComString:sub(1, 3) .. Globals.decimalCharacter .. currentComString:sub(4, 7)
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
