local Validation = require("vhf_helper.state.validation")
local Datarefs = require("vhf_helper.state.datarefs")
local Panels = require("vhf_helper.state.panels")
local Config = require("vhf_helper.state.config")
local PublicInterface = require("vhf_helper.public_interface")

local M = {}
M.bootstrap = function()
    vhfHelperPackageExport = {}
    vhfHelperPackageExport.test = {}
    vhfHelperPackageExport.test.comFrequencyValidator = Validation.comFrequencyValidator
    vhfHelperPackageExport.test.navFrequencyValidator = Validation.navFrequencyValidator
    vhfHelperPackageExport.test.transponderCodeValidator = Validation.transponderCodeValidator
    vhfHelperPackageExport.test.baroValidator = Validation.baroValidator

    vhfHelperPackageExport.test.activatePublicInterface = PublicInterface.activatePublicInterface
    vhfHelperPackageExport.test.deactivatePublicInterface = PublicInterface.deactivatePublicInterface

    vhfHelperPackageExport.test.Config = Config.Config
    vhfHelperPackageExport.test.vhfHelperLoop = vhfHelperLoop
    vhfHelperPackageExport.test.vhfHelperMainWindow = vhfHelperMainWindow
    vhfHelperPackageExport.test.vhfHelperSideWindow = vhfHelperSideWindow
    vhfHelperPackageExport.test.vhfHelperMulticrewManager = vhfHelperMulticrewManager
    vhfHelperPackageExport.test.vhfHelperCompatibilityManager = vhfHelperCompatibilityManager

    vhfHelperPackageExport.test.comLinkedDatarefs = Datarefs.comLinkedDatarefs
    vhfHelperPackageExport.test.navLinkedDatarefs = Datarefs.navLinkedDatarefs
    vhfHelperPackageExport.test.transponderModeToDescriptor = Datarefs.transponderModeToDescriptor
end
return M
