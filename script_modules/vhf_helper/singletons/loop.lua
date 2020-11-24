local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Datarefs = require("vhf_helper.state.datarefs")

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

    TRACK_ISSUE(
        "FlyWithLua",
        "Macros can not be disabled programmatically. The dot in the FlyWithLua macros menu will only disappear if clicked manually," ..
            "\n" .. "but is not coupled in any way with panel visibility or existence.",
        "Mention that this is a known issue"
    )
    function vhfHelperLoop:bootstrap()
        self:_reset()
        Config.Config:load()

        local windowIsSupposedToBeVisible = false
        if (Config.Config:getInitialWindowVisibility() == true) then
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
        do_every_frame("vhfHelperMainWindow:everyFrameLoop()")
        do_every_frame("vhfHelperMulticrewManager:everyFrameLoop()")
    end

    function vhfHelperLoop:everyFrameLoop()
        if (not self.alreadyInitialized) then
            return
        end

        for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
            ldr:loopUpdate()
        end

        Config.Config:save()
    end

    TRACK_ISSUE(
        "Tech Debt",
        "Default X-Plane datarefs should be available at any time. If one of them ever changes via an X-Plane update, initialization never finishes."
    )
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

local M = {}
M.bootstrap = function()
    vhfHelperLoop:bootstrap()
end
return M
