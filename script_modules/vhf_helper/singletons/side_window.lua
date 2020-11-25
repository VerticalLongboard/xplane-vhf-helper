local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Configuration = require("vhf_helper.shared_components.configuration")
local Utilities = require("vhf_helper.shared_components.utilities")
local InlineButtonBlob = require("vhf_helper.shared_components.inline_button_blob")

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

        self.Constants.MulticrewStateToMessage = {}
        self.Constants.MulticrewStateToMessage[vhfHelperMulticrewManager.Constants.State.MulticrewAvailable] = {
            "You're all set for multicrew. Have fun!",
            Globals.Colors.a320Green
        }
        self.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
            ] = {
            "No SmartCopilot configuration found for your current aircraft.",
            Globals.Colors.a320Blue
        }
        self.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationInvalid
            ] = {
            "Your smartcopilot.cfg is invalid.\nRe-install or fix your SmartCopilot setup first.\nIf you're lucky, it may still run.",
            Globals.Colors.a320Red
        }
        self.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationPatchingFailed
            ] = {
            "Patching your smartcopilot.cfg failed. Patch it manually.",
            Globals.Colors.a320Red
        }
        self.Constants.MulticrewStateToMessage[vhfHelperMulticrewManager.Constants.State.RestartRequiredAfterPatch] = {
            "You're almost ready, smartcopilot.cfg got patched a moment ago.\nRestart SmartCopilot and/or X-Plane!",
            Globals.Colors.a320Blue
        }

        self.FeedbackLinkBlob = InlineButtonBlob:new()
        self.FeedbackLinkBlob:addTextWithoutNewline(
            "How VR Radio Helper work for you? Please leave feedback at Github:"
        )

        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLinkBlob:addCustomCallbackButton(
            "Click: https://github.com/VerticalLongboard/xplane-vhf-helper",
            function(buttonTitle)
                os.execute(
                    'start "" https://github.com/VerticalLongboard/xplane-vhf-helper/issues/new?labels=Feedback^&title=New%20VR%20Radio%20Helper%20Feedback^&body=Please%20leave%20your%20feedback%20here.%20Thanks%20for%20taking%20your%20time!'
                )
            end
        )
        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLinkBlob:addTextWithoutNewline("(Opens in default browser on Windows)")
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
            minWidthWithoutScrollbars = 500
            minHeightWithoutScrollbars = 300
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

        imgui.TextUnformatted("")
        imgui.TextUnformatted("Multicrew Support")
        imgui.Separator()

        local multicrewState = vhfHelperMulticrewManager:getState()

        imgui.PushStyleColor(imgui.constant.Col.Text, self.Constants.MulticrewStateToMessage[multicrewState][2])
        imgui.TextUnformatted(self.Constants.MulticrewStateToMessage[multicrewState][1])
        local lastMulticrewError = vhfHelperMulticrewManager:getLastErrorOrNil()
        if (lastMulticrewError ~= nil) then
            imgui.TextUnformatted(Utilities.newlineBreakStringAtWidth(lastMulticrewError, 40))
        end
        imgui.PopStyleColor()

        imgui.TextUnformatted("")
        imgui.TextUnformatted("Feedback :-)")
        imgui.Separator()
        self.FeedbackLinkBlob:renderToCanvas()

        -- imgui.TextUnformatted("")

        -- imgui.TextUnformatted("")
        -- imgui.TextUnformatted("Plane Compatibility")
        -- imgui.Separator()
        -- imgui.TextUnformatted(PLANE_ICAO)
        -- imgui.TextUnformatted(XPLANE_VERSION)
        -- imgui.TextUnformatted(AIRCRAFT_PATH)
        -- imgui.TextUnformatted(AIRCRAFT_FILENAME)
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperSideWindow:bootstrap()
end
return M
