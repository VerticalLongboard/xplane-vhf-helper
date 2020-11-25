local MulticrewManager = require("vhf_helper.singletons.multicrew_manager")
local Utilities = require("shared_components.utilities")

TestMulticrew = {
    Constants = {}
}

function TestMulticrew:setUp()
    vhfHelperMulticrewManager:_reset()
    self.Constants.SmartCopilotFilePath =
        SCRIPT_DIRECTORY .. vhfHelperMulticrewManager.Constants.SmartCopilotConfigurationFileName
    os.remove(self.Constants.SmartCopilotFilePath)
end

function TestMulticrew:tearDown()
    os.remove(self.Constants.SmartCopilotFilePath)
end

function TestMulticrew:testFreshMulticrewManagerIsBootstrapping()
    luaUnit.assertEquals(vhfHelperMulticrewManager:getState(), vhfHelperMulticrewManager.Constants.State.Bootstrapping)
end

function TestMulticrew:testNonExistingSmartCopilotConfigurationIsHandledProperly()
    MulticrewManager.bootstrap()
    luaUnit.assertEquals(
        vhfHelperMulticrewManager:getState(),
        vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
    )
end

function TestMulticrew:testObviouslyInvalidSmartCopilotConfigurationIsHandledProperly()
    Utilities.overwriteContentInFile(self.Constants.SmartCopilotFilePath, "dddkdjfkdsjfk\n")

    MulticrewManager.bootstrap()
    luaUnit.assertEquals(
        vhfHelperMulticrewManager:getState(),
        vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationInvalid
    )
end

function TestMulticrew:testAlreadyCorrectSetupIsDetectedAsSuch()
    Utilities.copyFile(".\\test\\multicrew\\valid_smartcopilot\\smartcopilot.cfg", self.Constants.SmartCopilotFilePath)

    MulticrewManager.bootstrap()
    luaUnit.assertEquals(
        vhfHelperMulticrewManager:getState(),
        vhfHelperMulticrewManager.Constants.State.MulticrewAvailable
    )
end
function TestMulticrew:testIncorrectSetupIsPatchedAndWorksAfterRestart()
    Utilities.copyFile(
        ".\\test\\multicrew\\invalid_smartcopilot\\smartcopilot.cfg",
        self.Constants.SmartCopilotFilePath
    )

    MulticrewManager.bootstrap()
    luaUnit.assertEquals(
        vhfHelperMulticrewManager:getState(),
        vhfHelperMulticrewManager.Constants.State.RestartRequiredAfterPatch
    )

    MulticrewManager.bootstrap()
    luaUnit.assertEquals(
        vhfHelperMulticrewManager:getState(),
        vhfHelperMulticrewManager.Constants.State.MulticrewAvailable
    )
end
