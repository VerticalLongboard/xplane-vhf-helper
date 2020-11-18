local Configuration = require("vhf_helper.configuration")
local PublicInterface = require("vhf_helper.public_interface")
local Panels = require("vhf_helper.panels")
local Globals = require("vhf_helper.globals")

-- FlyWithLua Issue: Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/
function renderVhfHelperMainWindowToCanvas()
    vhfHelperMainWindow:renderToCanvas()
end

function closeVhfHelperMainWindow()
    -- FlyWithLua Issue: The close function is called asynchronously so quickly closing and opening the panel will close it again quickly after.
    -- Destroy it anyway to keep public interface in line with panel visibility.
    vhfHelperMainWindow:destroy()
end

local vhfHelperMainWindowSingleton
do
    vhfHelperMainWindow = {}

    function vhfHelperMainWindow:_reset()
        self.Constants = {defaultWindowName = Globals.readableScriptName}
        self.window = nil
        self.currentPanel = Panels.comFrequencyPanel
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

        globalFontScaleDescriptor = Globals.trim(Configuration.Config:getValue("Windows", "GlobalFontScale", "big"))
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

        Configuration.Config:setValue("Windows", "MainWindowVisibility", Globals.windowVisibilityVisible)
        Configuration.Config:save()

        PublicInterface.activatePublicInterface()
    end

    function vhfHelperMainWindow:destroy()
        if (self.window == nil) then
            return
        end

        float_wnd_destroy(self.window)
        self.window = nil

        Configuration.Config:setValue("Windows", "MainWindowVisibility", Globals.windowVisibilityHidden)
        Configuration.Config:save()

        PublicInterface.deactivatePublicInterface()
    end

    function vhfHelperMainWindow:show(value)
        -- FlyWithLua Issue: Using float_wnd_set_visible only works for _hiding_ the panel, not for making it visible again.
        -- Create and destroy for now.
        if (self.window == nil and value) then
            self:create()
        elseif (self.window ~= nil and not value) then
            self:destroy()
        end
    end

    function vhfHelperMainWindow:toggle()
        self:show(self.window == nil)
    end

    function vhfHelperMainWindow:renderToCanvas()
        local slightlyBrighterDefaultButtonColor = 0xFF7F5634
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Globals.Colors.defaultImguiButtonBackground)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, slightlyBrighterDefaultButtonColor)

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

        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end

    function vhfHelperMainWindow:_renderPanelButton(panel)
        imguiUtils:renderActiveInactiveButton(
            " " .. panel.descriptor .. " ",
            self.currentPanel == panel,
            function()
                self.currentPanel = panel
            end
        )
    end
end
