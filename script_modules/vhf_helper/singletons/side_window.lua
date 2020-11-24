local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Configuration = require("vhf_helper.shared_components.configuration")

TRACK_ISSUE(
    "FlyWithLua",
    "Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/",
    "Create global onClose and render for side window"
)
function renderVhfHelperSideWindowToCanvas()
    vhfHelperSideWindow:renderToCanvas()
end

TRACK_ISSUE(
    "FlyWithLua",
    "The close function is called asynchronously so quickly closing and opening the panel will close it again quickly after.",
    "Mention that this is a known issue"
)
function closeVhfHelperSideWindow()
    vhfHelperSideWindow:destroy()
end

local vhfHelperSideWindowSingleton
do
    vhfHelperSideWindow = {}

    function vhfHelperSideWindow:_reset()
        self.Constants = {defaultWindowName = Globals.sidePanelName}
        self.window = nil
    end

    function vhfHelperSideWindow:bootstrap()
        self:_reset()
    end

    function vhfHelperSideWindow:create()
        if (self.window ~= nil) then
            return
        end

        local minWidthWithoutScrollbars = nil
        local minHeightWithoutScrollbars = nil

        globalFontScaleDescriptor = Globals.trim(Config.Config:getValue("Windows", "GlobalFontScale", "big"))
        if (globalFontScaleDescriptor == "huge") then
            minWidthWithoutScrollbars = 300
            minHeightWithoutScrollbars = 300
        elseif (globalFontScaleDescriptor == "big") then
            minWidthWithoutScrollbars = 400
            minHeightWithoutScrollbars = 260
        else
            minWidthWithoutScrollbars = 100
            minHeightWithoutScrollbars = 100
        end

        self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
        float_wnd_set_title(self.window, self.Constants.defaultWindowName)
        float_wnd_set_imgui_builder(self.window, "renderVhfHelperSideWindowToCanvas")
        float_wnd_set_onclose(self.window, "closeVhfHelperSideWindow")
    end

    function vhfHelperSideWindow:destroy()
        if (self.window == nil) then
            return
        end

        float_wnd_destroy(self.window)
        self.window = nil
    end

    TRACK_ISSUE("FlyWithLua", "float_wnd_set_visible", "Destroy and show side window.")
    function vhfHelperSideWindow:show(value)
        if (self.window == nil and value) then
            self:create()
        elseif (self.window ~= nil and not value) then
            self:destroy()
        end
    end

    function vhfHelperSideWindow:toggle()
        self:show(self.window == nil)
    end

    function vhfHelperSideWindow:renderToCanvas()
        imgui.TextUnformatted("Audio")
        imgui.Separator()

        local speakNumbersLocallyChanged, newSpeakNumbersLocally =
            imgui.Checkbox("Speak numbers when switching yourself", Config.Config:getSpeakNumbersLocally())

        if (speakNumbersLocallyChanged) then
            Config.Config:setSpeakNumbersLocally(newSpeakNumbersLocally)
        end

        local speakRemoteNumbersChanged, newSpeakRemoteNumbers =
            imgui.Checkbox("Speak numbers when switched remotely", Config.Config:getSpeakRemoteNumbers())

        if (speakRemoteNumbersChanged) then
            Config.Config:setSpeakRemoteNumbers(newSpeakRemoteNumbers)
        end

        -- imgui.TextUnformatted("")
        -- imgui.TextUnformatted("Multicrew Support")
        -- imgui.Separator()
        -- imgui.TextUnformatted("Your smartcopilot.cfg is set up correctly for multicrew.")

        -- imgui.TextUnformatted("")
        -- imgui.TextUnformatted("Plane Compatibility")
        -- imgui.Separator()
        -- imgui.TextUnformatted(PLANE_ICAO)
        -- imgui.TextUnformatted(XPLANE_VERSION)
        -- imgui.TextUnformatted(AIRCRAFT_PATH)
        -- imgui.TextUnformatted(AIRCRAFT_FILENAME)

        -- imgui.TextUnformatted("")
        -- imgui.TextUnformatted("Feedback :-)")
        -- imgui.Separator()
        -- imgui.TextUnformatted("https://github")
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperSideWindow:bootstrap()
end
return M
