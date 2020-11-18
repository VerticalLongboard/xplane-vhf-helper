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
