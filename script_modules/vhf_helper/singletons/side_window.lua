local Globals = require("vhf_helper.globals")
local Config = require("vhf_helper.state.config")
local Configuration = require("shared_components.configuration")
local Utilities = require("shared_components.utilities")
local InlineButtonBlob = require("shared_components.inline_button_blob")
local Notifications = require("vhf_helper.state.notifications")

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

local ClickableFeedbackBrowserLink
do
    ClickableFeedbackBrowserLink = {}

    function ClickableFeedbackBrowserLink:new()
        local newInstanceWithState = {
            timesBrowserOpened = 0
        }

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function ClickableFeedbackBrowserLink:addLinkToBlob(blob, linkTitle, url)
        blob:addCustomCallbackButton(
            linkTitle,
            function(buttonTitle)
                if (Utilities.openUrlInLocalDefaultBrowser(url)) then
                    self.timesBrowserOpened = self.timesBrowserOpened + 1
                    blob:addNewline()
                    blob:addColorTextWithoutNewline(
                        ("Opened web browser x%d"):format(self.timesBrowserOpened),
                        Globals.Colors.a320Blue
                    )
                else
                    blob:addNewline()
                    blob:addColorTextWithoutNewline("Error opening web browser", Globals.Colors.a320Blue)
                end
            end
        )
    end
end

local vhfHelperSideWindowSingleton
do
    vhfHelperSideWindow = {
        Constants = {
            defaultWindowName = Globals.sidePanelName
        },
        Notifications = {
            HaveALookAtMe = "SideWindow.HaveALookAtMe"
        }
    }

    function vhfHelperSideWindow:_reset()
        -- Notifications.notificationManager:postOnce(vhfHelperSideWindow.Notifications.HaveALookAtMe)

        self.window = nil

        vhfHelperSideWindow.Constants.MulticrewStateToMessage = {}
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.MulticrewAvailable
            ] = {
            "You're all set for multicrew. Have fun!",
            Globals.Colors.a320Green
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
            ] = {
            "No SmartCopilot configuration found for your current aircraft.",
            Globals.Colors.a320Blue
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationInvalid
            ] = {
            "Your smartcopilot.cfg is invalid and won't be touched.\nRe-install or fix your SmartCopilot setup first.\nIf you're lucky, it may still run.",
            Globals.Colors.a320Red
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationPatchingFailed
            ] = {
            "Patching your smartcopilot.cfg failed. Patch it manually.",
            Globals.Colors.a320Red
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.RestartRequiredAfterPatch
            ] = {
            "You're almost ready, smartcopilot.cfg got patched a moment ago.\nRestart SmartCopilot and/or X-Plane!",
            Globals.Colors.a320Orange
        }

        self.PlaneCompatibilityBlob = InlineButtonBlob:new()
        self.PlaneCompatibilityBlob:addTextWithoutNewline("If you think that something doesn't work correctly,")
        self.PlaneCompatibilityBlob:addNewline()
        self.PlaneCompatibilityBlob:addTextWithoutNewline("describe your findings at Github:")
        self.PlaneCompatibilityBlob:addNewline()
        self.PlaneCompatibilityLink = ClickableFeedbackBrowserLink:new()
        self.PlaneCompatibilityLink:addLinkToBlob(
            self.PlaneCompatibilityBlob,
            "Compatibility: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            self:_getUrlWithDiagnosticParams(
                ("https://github.com/VerticalLongboard/xplane-vhf-helper/issues/new?labels=PlaneCompatibility&title=New Plane Compatibility Report for ICAO %s&body=Your current plane is treated as a default plane. Since all features are enabled, you may have experienced issues. Please describe the behaviour you observed (Transponder modes don't match, Frequencies don't show up, COM can't be set etc.).\nThanks a lot for taking your time!\n\n**---YOUR REPORT HERE---**"):format(
                    PLANE_ICAO
                )
            )
        )

        TRACK_ISSUE("Feature", "Add version number to build.")
        self.UpdatesBlob = InlineButtonBlob:new()
        self.UpdatesBlob:addTextWithoutNewline(("You are using VR Radio Helper %s"):format("UNKNOWN_VERSION"))
        self.UpdatesBlob:addNewline()
        self.UpdatesBlob:addTextWithoutNewline(
            ("For news and updates, see the official Github page:"):format("UNKNOWN_VERSION")
        )
        self.UpdatesBlob:addNewline()
        self.UpdatesLink = ClickableFeedbackBrowserLink:new()
        self.UpdatesLink:addLinkToBlob(
            self.UpdatesBlob,
            "Latest Release: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            "https://github.com/VerticalLongboard/xplane-vhf-helper/releases/latest"
        )

        self.FeedbackLinkBlob = InlineButtonBlob:new()
        self.FeedbackLinkBlob:addTextWithoutNewline(
            "How does VR Radio Helper work for you? Please leave your feedback at Github:"
        )
        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLink = ClickableFeedbackBrowserLink:new()
        self.FeedbackLink:addLinkToBlob(
            self.FeedbackLinkBlob,
            "Feedback: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            self:_getUrlWithDiagnosticParams(
                "https://github.com/VerticalLongboard/xplane-vhf-helper/issues/new?labels=Feedback&title=New VR Radio Helper Feedback&body=Please leave your feedback here.\nThanks for taking your time!\n\n**---YOUR FEEDBACK HERE---**"
            )
        )
        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLinkBlob:addTextWithoutNewline("Much appreciated!")
    end

    function vhfHelperSideWindow:_getUrlWithDiagnosticParams(urlFirstPart)
        local diagnosticInfo =
            ("\n\n---\nThis diagnostic information helps making VR Radio Helper better, please keep it here:\n---\n" ..
            "- X-Plane Version: %s\n" .. "- System: %s\n" .. "- Plane Compatibility: %s\n"):format(
            XPLANE_VERSION,
            SYSTEM,
            vhfHelperCompatibilityManager:getPlaneCompatibilityIdString()
        )
        return urlFirstPart .. diagnosticInfo
    end

    function vhfHelperSideWindow:bootstrap()
        self:_reset()
    end

    function vhfHelperSideWindow:create()
        if (self.window ~= nil) then
            return
        end

        self:_reset()

        local minWidthWithoutScrollbars = nil
        local minHeightWithoutScrollbars = nil

        globalFontScaleDescriptor = Utilities.trim(Config.Config:getValue("Windows", "GlobalFontScale", "big"))
        if (globalFontScaleDescriptor == "huge") then
            minWidthWithoutScrollbars = 300
            minHeightWithoutScrollbars = 300
        elseif (globalFontScaleDescriptor == "big") then
            minWidthWithoutScrollbars = 550
            minHeightWithoutScrollbars = 500
        else
            minWidthWithoutScrollbars = 100
            minHeightWithoutScrollbars = 100
        end

        self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
        float_wnd_set_title(self.window, vhfHelperSideWindow.Constants.defaultWindowName)
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
        Globals.pushDefaultButtonColorsToImguiStack()

        self:_renderSectionHeader("Audio")

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
        self:_renderSectionHeader("Multicrew Support")

        local multicrewState = vhfHelperMulticrewManager:getState()

        local maxStringWidth = 60

        imgui.PushStyleColor(
            imgui.constant.Col.Text,
            vhfHelperSideWindow.Constants.MulticrewStateToMessage[multicrewState][2]
        )
        imgui.TextUnformatted(vhfHelperSideWindow.Constants.MulticrewStateToMessage[multicrewState][1])
        local lastMulticrewError = vhfHelperMulticrewManager:getLastErrorOrNil()
        if (lastMulticrewError ~= nil) then
            imgui.TextUnformatted(Utilities.newlineBreakStringAtWidth(lastMulticrewError, maxStringWidth))
        end
        imgui.PopStyleColor()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Plane Compatibility")

        local cc = vhfHelperCompatibilityManager:getCurrentConfiguration()

        if (cc.isDefaultPlane) then
            imgui.TextUnformatted("No compatibility information found.")
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
            imgui.TextUnformatted("All features are enabled, but may not work correctly.")
            imgui.PopStyleColor()
        else
            imgui.TextUnformatted("Your plane looks like a")
            imgui.SameLine()
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
            imgui.TextUnformatted(("%s"):format(cc.readableName))
            imgui.PopStyleColor()
            if (cc.hasKnownIssues) then
                imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
                imgui.TextUnformatted(("Known Issues: %s"):format(cc.knownIssuesText))
                imgui.PopStyleColor()
            end
        end

        imgui.TextUnformatted("")
        self.PlaneCompatibilityBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Updates")
        self.UpdatesBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Feedback :-)")
        self.FeedbackLinkBlob:renderToCanvas()

        Globals.popDefaultButtonColorsFromImguiStack()

        -- imgui.TextUnformatted(tostring(Notifications.notificationManager))

        -- for nid, pending in pairs(Notifications.notificationManager.notifications) do
        --     imgui.TextUnformatted(("nid=%s pending=%s"):format(nid, tostring(pending)))
        -- end
    end

    function vhfHelperSideWindow:_renderSectionHeader(title)
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFFAAAAAA)
        imgui.TextUnformatted(title)
        imgui.PopStyleColor()
        imgui.Separator()
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperSideWindow:bootstrap()
end
return M
