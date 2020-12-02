local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Panels = require("vhf_helper.state.panels")
local PublicInterface = require("vhf_helper.public_interface")
local Utilities = require("shared_components.utilities")
local LuaPlatform = require("lua_platform")
local Notifications = require("vhf_helper.state.notifications")

TRACK_ISSUE(
    "FlyWithLua",
    "Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/",
    "Create global render and onClose functions for main window."
)
function renderVhfHelperMainWindowToCanvas()
    vhfHelperMainWindow:renderToCanvas()
end

function closeVhfHelperMainWindow()
    if (not Globals.IssueWorkarounds.FlyWithLua.shouldCloseWindowNow(vhfHelperMainWindow)) then
        return
    end
    vhfHelperMainWindow:destroy()
end

local RADAR_PANEL_AVAILABLE = false

local vhfHelperMainWindowSingleton
do
    vhfHelperMainWindow = {
        Constants = {
            defaultWindowName = Globals.readableScriptName,
            SidePanelVisibleButtonTitle = "<",
            SidePanelHiddenButtonTitle = ">"
        }
    }

    function vhfHelperMainWindow:_reset()
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

        self:_reset()

        local minWidthWithoutScrollbars = nil
        local minHeightWithoutScrollbars = nil

        globalFontScaleDescriptor = Utilities.trim(Config.Config:getValue("Windows", "GlobalFontScale", "big"))
        if (globalFontScaleDescriptor == "huge") then
            globalFontScale = 3.0
            minWidthWithoutScrollbars = 380
            minHeightWithoutScrollbars = 460
        elseif (globalFontScaleDescriptor == "big") then
            globalFontScale = 2.0
            minWidthWithoutScrollbars = 258
            -- minHeightWithoutScrollbars = 344
            minHeightWithoutScrollbars = 315
        else
            globalFontScale = 1.0
            minWidthWithoutScrollbars = 150
            minHeightWithoutScrollbars = 190
        end

        Globals.defaultDummySize = 20.0 * globalFontScale

        self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
        float_wnd_set_title(self.window, vhfHelperMainWindow.Constants.defaultWindowName)
        float_wnd_set_imgui_builder(self.window, "renderVhfHelperMainWindowToCanvas")
        float_wnd_set_onclose(self.window, "closeVhfHelperMainWindow")

        Config.Config:setInitialWindowVisibility(true)

        PublicInterface.activatePublicInterface()

        Globals.IssueWorkarounds.FlyWithLua.timeTagWindowCreatedNow(vhfHelperMainWindow)
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
        Globals.pushDefaultsToImguiStack()

        self.currentPanel:renderToCanvas()

        imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
        imgui.Separator()
        imgui.PopStyleVar()
        imgui.Separator()

        imgui.SetWindowFontScale(0.6 * globalFontScale)

        self:_renderPanelButton(Panels.comFrequencyPanel, true)

        imgui.SameLine()
        self:_renderPanelButton(
            Panels.navFrequencyPanel,
            vhfHelperCompatibilityManager:getCurrentConfiguration().isNavFeatureEnabled
        )
        imgui.SameLine()
        self:_renderPanelButton(
            Panels.transponderCodePanel,
            vhfHelperCompatibilityManager:getCurrentConfiguration().isTransponderFeatureEnabled
        )
        imgui.SameLine()
        self:_renderPanelButton(
            Panels.baroPanel,
            vhfHelperCompatibilityManager:getCurrentConfiguration().isBarometerFeatureEnabled
        )

        imgui.SameLine()
        imgui.Dummy(34.0, 0.0)

        imgui.SameLine()
        self:_renderSidePanelButton()

        Globals.popDefaultsFromImguiStack()
    end

    function vhfHelperMainWindow:_renderSidePanelButton()
        local sidePanelButtonTitle = nil
        if (vhfHelperSideWindow:isVisible()) then
            sidePanelButtonTitle = vhfHelperMainWindow.Constants.SidePanelVisibleButtonTitle
        else
            sidePanelButtonTitle = vhfHelperMainWindow.Constants.SidePanelHiddenButtonTitle
        end

        if (vhfHelperSideWindow:areAnyNotificationsPending()) then
            if
                (Globals.ImguiUtils.renderButtonWithColors(
                    sidePanelButtonTitle,
                    Globals.Colors.black,
                    Utilities.getBlinkingColor(0xFFFFFFFF, 0.4, 5.0),
                    Globals.Colors.white,
                    Globals.Colors.white
                ))
             then
                self.toggleSideWindowSoon = true
            end
        else
            if (imgui.Button(sidePanelButtonTitle)) then
                self.toggleSideWindowSoon = true
            end
        end
    end

    function vhfHelperMainWindow:everyFrameLoop()
        if (self.toggleSideWindowSoon) then
            vhfHelperSideWindow:toggle()
            self.toggleSideWindowSoon = false
        end
    end

    function vhfHelperMainWindow:_renderPanelButton(panel, enabled)
        Globals.ImguiUtils.renderActiveInactiveButton(
            ("%s"):format(panel.panelTitle),
            self.currentPanel == panel,
            enabled,
            function()
                self.currentPanel = panel
                self.currentPanel:show()
            end
        )
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperMainWindow:bootstrap()
end
return M
