local Datarefs = require("vhf_helper.state.datarefs")
local Utilities = require("vhf_helper.shared_components.utilities")
local IniEditor = require("vhf_helper.shared_components.ini_editor")

local vhfHelperMulticrewManagerSingleton
do
    vhfHelperMulticrewManager = {}

    function vhfHelperMulticrewManager:_reset()
        self.Constants = {
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

        self.lastError = nil
        self.state = self.Constants.State.Bootstrapping
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
            self.Constants.SmartCopilotConfigurationFileName

        if (not Utilities.fileExists(smartCopilotCfgPath)) then
            self.state = self.Constants.State.SmartCopilotConfigurationMissing
            return
        end

        local iniEditor = IniEditor:new()
        if (not iniEditor:loadFromFile(smartCopilotCfgPath)) then
            self.state = self.Constants.State.SmartCopilotConfigurationInvalid
            self.lastError = iniEditor:getLastErrorOrNil()
            return
        end
        if (iniEditor:getReadOnlyStructuredContent()[self.Constants.SmartCopilotTriggerSectionName] == nil) then
            self.state = self.Constants.State.SmartCopilotConfigurationInvalid
            return
        end

        local patchRequired = false

        for _, linkedDataref in pairs(Datarefs.allLinkedDatarefs) do
            if
                (not iniEditor:doesKeyValueExist(
                    self.Constants.SmartCopilotTriggerSectionName,
                    linkedDataref:getInterchangeDatarefName(),
                    "0"
                ))
             then
                patchRequired = true
            end
        end

        local allVhfHelperKeyValueLines = iniEditor:getAllKeyValueLinesByKeyMatcher(self.Constants.VhfHelperKeyMatcher)

        if (#allVhfHelperKeyValueLines ~= #Datarefs.allLinkedDatarefs) then
            patchRequired = true
        end

        if (patchRequired) then
            if (not self:_patchSmartCopilotConfiguration(iniEditor)) then
                self.state = self.Constants.State.SmartCopilotConfigurationPatchingFailed
            else
                self.state = self.Constants.State.RestartRequiredAfterPatch
            end
        else
            self.state = self.Constants.State.MulticrewAvailable
        end
    end

    function vhfHelperMulticrewManager:everyFrameLoop()
    end

    function vhfHelperMulticrewManager:_patchSmartCopilotConfiguration(iniEditor)
        iniEditor:removeAllKeyValueLinesByKeyMatcher(self.Constants.VhfHelperKeyMatcher)

        for _, linkedDataref in pairs(Datarefs.allLinkedDatarefs) do
            iniEditor:addKeyValueLine(
                self.Constants.SmartCopilotTriggerSectionName,
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
