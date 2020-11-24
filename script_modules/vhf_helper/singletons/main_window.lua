local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Panels = require("vhf_helper.state.panels")
local PublicInterface = require("vhf_helper.public_interface")

TRACK_ISSUE(
    "FlyWithLua",
    "Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/",
    "Create global render and onClose functions for main window."
)
function renderVhfHelperMainWindowToCanvas()
    vhfHelperMainWindow:renderToCanvas()
end

TRACK_ISSUE(
    "FlyWithLua",
    "The close function is called asynchronously so quickly closing and opening the panel will close it again quickly after." ..
        "\n" ..
            "Since float_wnd_destroy does call the onClose function as well and windows cannot be made visible again," ..
                "\n" ..
                    "destroying again is the only viable way. Not having a separate visible-invisible creation-destroy cycle breaks public interface activation :-(",
    "Destroy it anyway to keep at least public interface in line with panel visibility."
)

function closeVhfHelperMainWindow()
    vhfHelperMainWindow:destroy()
end

local vhfHelperMainWindowSingleton
do
    vhfHelperMainWindow = {}

    function vhfHelperMainWindow:_reset()
        self.Constants = {defaultWindowName = Globals.readableScriptName}
        self.window = nil
        self.currentPanel = Panels.comFrequencyPanel
        self.toggleSideWindowSoon = false
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

        globalFontScaleDescriptor = Globals.trim(Config.Config:getValue("Windows", "GlobalFontScale", "big"))
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

        Config.Config:setInitialWindowVisibility(true)

        PublicInterface.activatePublicInterface()
    end

    function vhfHelperMainWindow:destroy()
        if (self.window == nil) then
            return
        end

        float_wnd_destroy(self.window)
        self.window = nil

        Config.Config:setInitialWindowVisibility(false)

        PublicInterface.deactivatePublicInterface()
    end

    TRACK_ISSUE(
        "FlyWithLua",
        "Using float_wnd_set_visible only works for _hiding_ the panel, not for making it visible again.",
        "Create and destroy main window for now."
    )
    function vhfHelperMainWindow:show(value)
        if (self.window == nil and value) then
            self:create()
        elseif (self.window ~= nil and not value) then
            self:destroy()
        end
    end

    function vhfHelperMainWindow:toggle()
        self:show(self.window == nil)
    end

    TRACK_ISSUE(
        "Imgui",
        "Creating a window while rendering another one is not allowed for some reason.",
        "Delay creation till finishing the current render function via storing an additional boolean."
    )
    function vhfHelperMainWindow:renderToCanvas()
        Globals.pushDefaultButtonColorsToImguiStack()

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

        if (imgui.Button(">")) then
            self.toggleSideWindowSoon = true
        end

        Globals.popDefaultButtonColorsFromImguiStack()
    end

    function vhfHelperMainWindow:everyFrameLoop()
        if (self.toggleSideWindowSoon) then
            vhfHelperSideWindow:toggle()
            self.toggleSideWindowSoon = false
        end
    end

    function vhfHelperMainWindow:_renderPanelButton(panel)
        Globals.ImguiUtils:renderActiveInactiveButton(
            panel.descriptor,
            self.currentPanel == panel,
            function()
                self.currentPanel = panel
            end
        )
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperMainWindow:bootstrap()
end
return M
