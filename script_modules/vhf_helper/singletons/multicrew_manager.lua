local Datarefs = require("vhf_helper.state.datarefs")
local Utilities = require("shared_components.utilities")
local IniEditor = require("shared_components.ini_editor")

local vhfHelperMulticrewManagerSingleton
do
    vhfHelperMulticrewManager = {
        Constants = {
            SmartCopilotConfigurationFileName = "smartcopilot.cfg",
            VhfHelperTriggerPrefix = "VHFHelper/",
            VhfHelperKeyMatcher = "^VHFHelper/.-$",
            SmartCopilotTriggerSectionName = "TRIGGERS",
            State = {
                Bootstrapping = "Bootstrapping",
                MulticrewAvailable = "MulticrewAvailable",
                SmartCopilotConfigurationMissing = "SmartCopilotConfigurationMissing",
                SmartCopilotConfigurationInvalid = "SmartCopilotConfigurationInvalid",
                SmartCopilotConfigurationPatchingFailed = "SmartCopilotConfigurationPatchingFailed",
                RestartRequiredAfterPatch = "RestartRequiredAfterPatch"
            }
        }
    }

    function vhfHelperMulticrewManager:_reset()
        self.lastError = nil
        self.state = vhfHelperMulticrewManager.Constants.State.Bootstrapping
    end

    function vhfHelperMulticrewManager:getLastErrorOrNil()
        return self.lastError
    end

    function vhfHelperMulticrewManager:bootstrap()
        self:_reset()
        self:_setupMulticrew()
    end

    function vhfHelperMulticrewManager:getState()
        return self.state
    end

    function vhfHelperMulticrewManager:_setupMulticrew()
        local smartCopilotCfgPath =
            vhfHelperCompatibilityManager:getCurrentAircraftBaseDirectory() ..
            vhfHelperMulticrewManager.Constants.SmartCopilotConfigurationFileName

        if (not Utilities.fileExists(smartCopilotCfgPath)) then
            self.state = vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
            return
        end

        local iniEditor = IniEditor:new()
        if (not iniEditor:loadFromFile(smartCopilotCfgPath, IniEditor.LoadModes.IgnoreDuplicateKeys)) then
            self.state = vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationInvalid
            self.lastError = iniEditor:getLastErrorOrNil()
            return
        end
        if
            (iniEditor:getReadOnlyStructuredContent()[vhfHelperMulticrewManager.Constants.SmartCopilotTriggerSectionName] ==
                nil)
         then
            self.state = vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationInvalid
            return
        end

        local patchRequired = false

        for _, linkedDataref in pairs(Datarefs.allLinkedDatarefs) do
            if
                (not iniEditor:doesKeyValueExist(
                    vhfHelperMulticrewManager.Constants.SmartCopilotTriggerSectionName,
                    linkedDataref:getInterchangeDatarefName(),
                    "0"
                ))
             then
                patchRequired = true
            end
        end

        local allVhfHelperKeyValueLines =
            iniEditor:getAllKeyValueLinesByKeyMatcher(vhfHelperMulticrewManager.Constants.VhfHelperKeyMatcher)

        if (#allVhfHelperKeyValueLines ~= #Datarefs.allLinkedDatarefs) then
            patchRequired = true
        end

        if (patchRequired) then
            if (not self:_patchSmartCopilotConfiguration(iniEditor)) then
                self.state = vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationPatchingFailed
            else
                self.state = vhfHelperMulticrewManager.Constants.State.RestartRequiredAfterPatch
            end
        else
            self.state = vhfHelperMulticrewManager.Constants.State.MulticrewAvailable
        end
    end

    function vhfHelperMulticrewManager:everyFrameLoop()
    end

    function vhfHelperMulticrewManager:_patchSmartCopilotConfiguration(iniEditor)
        iniEditor:removeAllKeyValueLinesByKeyMatcher(vhfHelperMulticrewManager.Constants.VhfHelperKeyMatcher)

        for _, linkedDataref in pairs(Datarefs.allLinkedDatarefs) do
            iniEditor:addKeyValueLine(
                vhfHelperMulticrewManager.Constants.SmartCopilotTriggerSectionName,
                linkedDataref:getInterchangeDatarefName(),
                "0"
            )
        end

        return iniEditor:saveToFile()
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperMulticrewManager:bootstrap()
end
return M
