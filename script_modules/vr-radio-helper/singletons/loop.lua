local Globals = require("vr-radio-helper.globals")
local Config = require("vr-radio-helper.state.config")
local Datarefs = require("vr-radio-helper.state.datarefs")
local LuaPlatform = require("lua_platform")
local Panels = require("vr-radio-helper.state.panels")
local InitializationItem = require("vr-radio-helper.shared_components.initialization_item")

local DatarefInitializationItem
do
    DatarefInitializationItem = InitializationItem:new()

    Globals.OVERRIDE(DatarefInitializationItem._canInitializeNow)
    function DatarefInitializationItem:_canInitializeNow()
        for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
            if (not ldr:isLocalLinkedDatarefAvailable()) then
                return false
            end
        end

        return true
    end

    Globals.OVERRIDE(DatarefInitializationItem._initializeNow)
    function DatarefInitializationItem:_initializeNow()
        for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
            ldr:initialize()
        end
    end
end

local VatsimbriefHelperEventBusInitializationItem
do
    VatsimbriefHelperEventBusInitializationItem = InitializationItem:new()

    Globals.OVERRIDE(VatsimbriefHelperEventBusInitializationItem._canInitializeNow)
    function VatsimbriefHelperEventBusInitializationItem:_canInitializeNow()
        return VatsimbriefHelperEventBus ~= nil
    end

    Globals.OVERRIDE(VatsimbriefHelperEventBusInitializationItem._initializeNow)
    function VatsimbriefHelperEventBusInitializationItem:_initializeNow()
        VatsimbriefHelperEventBus.on(
            VatsimbriefHelperEventOnVatsimDataRefreshed,
            function()
                Panels.comFrequencyPanel:triggerStationInfoUpdate()
            end
        )
    end
end

local vhfHelperLoopSingleton
do
    vhfHelperLoop = {}

    function vhfHelperLoop:isInitialized()
        return self.alreadyInitializedCompletely
    end

    function vhfHelperLoop:_reset()
        self.Constants = {
            defaultMacroName = Globals.readableScriptName
        }
        self.alreadyInitializedCompletely = false
        self.lastFrameTime = LuaPlatform.Time.now()
        self.dt = self.lastFrameTime + 1 / 60.0

        self.datarefInitialization = DatarefInitializationItem:new(5.0, "DatarefInitialization")
        self.vatsimbriefHelperInitialization =
            VatsimbriefHelperEventBusInitializationItem:new(5.0, "VatsimbriefHelperEventBusInitialization")
    end

    TRACK_ISSUE(
        "FlyWithLua",
        MULTILINE_TEXT(
            "Macros can not be disabled programmatically. The dot in the FlyWithLua macros menu will only disappear if clicked manually,",
            "but is not coupled in any way with panel visibility or existence."
        ),
        "Mention that this is a known issue."
    )
    function vhfHelperLoop:bootstrap()
        self:_reset()

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
        if (self.alreadyInitializedCompletely) then
            return
        end

        if (self.datarefInitialization:tryInitialize()) then
            do_every_frame("vhfHelperLoop:everyFrameLoop()")
            do_every_frame("vhfHelperMainWindow:everyFrameLoop()")
        end
        TRACK_ISSUE(
            "Tech Debt",
            "If dataref initialization times out, VR Radio Helper is in a zombie state. Display a warning instead of just ignoring that."
        )

        if (not self.vatsimbriefHelperInitialization:tryInitialize()) then
            return
        end

        self.alreadyInitializedCompletely = true
    end

    function vhfHelperLoop:everyFrameLoop()
        local now = LuaPlatform.Time.now()
        self.dt = now - self.lastFrameTime
        self.lastFrameTime = now

        if (self.datarefInitialization:hasBeenInitialized()) then
            for _, ldr in pairs(Datarefs.allLinkedDatarefs) do
                ldr:loopUpdate()
            end

            Config.Config:save()
        end

        if (not self.alreadyInitializedCompletely) then
            return
        end
    end

    function vhfHelperLoop:getDt()
        return self.dt
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperLoop:bootstrap()
end
return M
