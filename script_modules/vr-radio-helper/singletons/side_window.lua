local Globals = require("vr-radio-helper.globals")
local Config = require("vr-radio-helper.state.config")
local Configuration = require("vr-radio-helper.shared_components.configuration")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local InlineButtonBlob = require("vr-radio-helper.shared_components.inline_button_blob")
local Notifications = require("vr-radio-helper.state.notifications")
local LuaPlatform = require("lua_platform")
local VatsimData = require("vr-radio-helper.state.vatsim_data")
local Panels = require("vr-radio-helper.state.panels")

TRACK_ISSUE(
    "FlyWithLua",
    "Functions passed to float_wnd_set_imgui_builder and float_wnd_set_onclose can only exist outside of tables :-/",
    "Create global onClose and render for side window"
)
function renderVhfHelperSideWindowToCanvas()
    vhfHelperSideWindow:renderToCanvas()
end

function closeVhfHelperSideWindow()
    if (not Globals.IssueWorkarounds.FlyWithLua.shouldCloseWindowNow(vhfHelperSideWindow)) then
        return
    end
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
            HaveALookAtMe = "SideWindow_HaveALookAtMe",
            VatsimDataAvailable = "SideWindow_VatsimDataAvailable"
        }
    }

    function vhfHelperSideWindow:_reset()
        self.window = nil
    end

    function vhfHelperSideWindow:_createUiItems()
        self.pendingMulticrewNotification =
            Notifications.manager:isPending(vhfHelperMulticrewManager.Notifications.StateChange)
        self.pendingCompatibilityNotification =
            Notifications.manager:isPending(vhfHelperCompatibilityManager.Notifications.CompatibilityUpdate)
        self.pendingVatsimDataNotification =
            Notifications.manager:isPending(vhfHelperSideWindow.Notifications.VatsimDataAvailable)

        Notifications.manager:acknowledge(vhfHelperSideWindow.Notifications.HaveALookAtMe)
        Notifications.manager:acknowledge(vhfHelperSideWindow.Notifications.VatsimDataAvailable)
        Notifications.manager:acknowledge(vhfHelperCompatibilityManager.Notifications.CompatibilityUpdate)
        Notifications.manager:acknowledge(vhfHelperMulticrewManager.Notifications.StateChange)

        vhfHelperSideWindow.Constants.MulticrewStateToMessage = {}
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[vhfHelperMulticrewManager.Constants.State.Bootstrapping] = {
            "Multicrew setup failed. That means X-Plane and/or FlyWithLua are not setup correctly.",
            Globals.Colors.a320Red
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.MulticrewAvailable
            ] = {
            "You're all set for multicrew. Have fun!",
            Globals.Colors.a320Green
        }
        vhfHelperSideWindow.Constants.MulticrewStateToMessage[
                vhfHelperMulticrewManager.Constants.State.SmartCopilotConfigurationMissing
            ] = {
            "No SmartCopilot installation found for your current aircraft.",
            Globals.Colors.a320Orange
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

        self.VatsimDataBlob = InlineButtonBlob:new()
        local VatsimDataColor = Globals.Colors.white

        if (VatsimData.isVatsimbriefHelperAvailable()) then
            if (self.pendingVatsimDataNotification) then
                VatsimDataColor = Globals.Colors.a320Green
            else
                VatsimDataColor = Globals.Colors.a320Blue
            end

            self.VatsimDataBlob:addColorTextWithoutNewline(
                "Vatsimbrief Helper is installed and available. ",
                VatsimDataColor
            )
        else
            if (self.pendingVatsimDataNotification) then
                VatsimDataColor = Globals.Colors.a320Orange
            end
            self.VatsimDataBlob:addColorTextWithoutNewline(
                "Vatsimbrief Helper is not installed or incompatible.",
                VatsimDataColor
            )
            self.VatsimDataBlob:addNewline()
            self.VatsimDataBlob:addColorTextWithoutNewline(
                "Update VR Radio Helper and/or Vatsimbrief Helper.",
                VatsimDataColor
            )

            self.VatsimDataBlob:addNewline()
            ClickableFeedbackBrowserLink:new():addLinkToBlob(
                self.VatsimDataBlob,
                "Vatsimbrief Helper: https://github.com/RedXi/vatsimbrief-helper/",
                "https://github.com/RedXi/vatsimbrief-helper"
            )
        end

        self.PlaneCompatibilityBlob = InlineButtonBlob:new()
        local cc = vhfHelperCompatibilityManager:getCurrentConfiguration()

        local compatColor = Globals.Colors.white
        if (cc.isDefaultPlane) then
            self.PlaneCompatibilityBlob:addTextWithoutNewline(
                "No compatibility information for your current plane found."
            )
            self.PlaneCompatibilityBlob:addNewline()

            if (self.pendingCompatibilityNotification) then
                compatColor = Globals.Colors.a320Orange
            else
                compatColor = Globals.Colors.white
            end

            self.PlaneCompatibilityBlob:addColorTextWithoutNewline(
                "All features are enabled, but some may not work correctly.",
                compatColor
            )
        else
            self.PlaneCompatibilityBlob:addTextWithoutNewline("Your plane looks like a ")
            self.PlaneCompatibilityBlob:addColorTextWithoutNewline(cc.readableName, Globals.Colors.a320Blue)

            if (cc.hasKnownIssues) then
                if (self.pendingCompatibilityNotification) then
                    compatColor = Globals.Colors.a320Red
                else
                    compatColor = Globals.Colors.white
                end

                self.PlaneCompatibilityBlob:addNewline()
                self.PlaneCompatibilityBlob:addColorTextWithoutNewline(
                    ("Known Issues: %s"):format(cc.knownIssuesText),
                    compatColor
                )
            end
        end

        self.PlaneCompatibilityBlob:addNewline()
        self.PlaneCompatibilityBlob:addTextWithoutNewline(" ")
        self.PlaneCompatibilityBlob:addNewline()

        if (self.pendingCompatibilityNotification) then
            compatColor = Globals.Colors.a320Orange
        end
        self.PlaneCompatibilityBlob:addColorTextWithoutNewline(
            "If you think that something doesn't work correctly,",
            compatColor
        )
        self.PlaneCompatibilityBlob:addNewline()
        self.PlaneCompatibilityBlob:addColorTextWithoutNewline(
            "describe your findings at Github (click link):",
            compatColor
        )
        self.PlaneCompatibilityBlob:addNewline()
        ClickableFeedbackBrowserLink:new():addLinkToBlob(
            self.PlaneCompatibilityBlob,
            "Compatibility: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            self:_getUrlWithDiagnosticParams(
                ("https://github.com/VerticalLongboard/xplane-vhf-helper/issues/new?labels=PlaneCompatibility&title=New Plane Compatibility Report for ICAO %s" ..
                    "&body=Your current plane is treated as a default plane. Since all features are enabled, you may have experienced issues." ..
                        " Please describe the behaviour you observed (Transponder modes don't match, Frequencies don't show up, COM can't be set etc.).\n" ..
                            "Thanks a lot for taking your time!\n\n**---YOUR REPORT HERE---**"):format(PLANE_ICAO)
            )
        )

        local buildTag = "UNKNOWN"
        local buildCommitHash = "UNKNOWN"
        logMsg(SCRIPT_DIRECTORY)
        local buildInfoPath = SCRIPT_DIRECTORY .. "..\\modules\\vr-radio-helper\\"
        local buildTagPath = buildInfoPath .. "release_tag.txt"
        if (Utilities.fileExists(buildTagPath)) then
            buildTag = Utilities.readAllContentFromFile(buildTagPath):gsub("\n", "")
        end

        local buildCommitHashPath = buildInfoPath .. "release_commit_hash.txt"
        if (Utilities.fileExists(buildCommitHashPath)) then
            buildCommitHash = Utilities.readAllContentFromFile(buildCommitHashPath):gsub("\n", "")
        end

        self.UpdatesBlob = InlineButtonBlob:new()
        self.UpdatesBlob:addTextWithoutNewline(
            ("You are using VR Radio Helper %s-%s"):format(buildTag, buildCommitHash)
        )
        self.UpdatesBlob:addNewline()
        self.UpdatesBlob:addTextWithoutNewline("For news and updates see the official Github page (click link):")
        self.UpdatesBlob:addNewline()
        ClickableFeedbackBrowserLink:new():addLinkToBlob(
            self.UpdatesBlob,
            "Latest Release: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            "https://github.com/VerticalLongboard/xplane-vhf-helper/releases/latest"
        )

        self.FeedbackLinkBlob = InlineButtonBlob:new()
        self.FeedbackLinkBlob:addTextWithoutNewline("How does VR Radio Helper work for you?")
        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLinkBlob:addTextWithoutNewline("Please leave your feedback at Github (click link):")
        self.FeedbackLinkBlob:addNewline()
        ClickableFeedbackBrowserLink:new():addLinkToBlob(
            self.FeedbackLinkBlob,
            "Feedback: https://github.com/VerticalLongboard/xplane-vhf-helper/...",
            self:_getUrlWithDiagnosticParams(
                "https://github.com/VerticalLongboard/xplane-vhf-helper/issues/new?labels=Feedback&title=New VR Radio Helper Feedback&body=Please leave your feedback here.\nThanks for taking your time!\n\n**---YOUR FEEDBACK HERE---**"
            )
        )
        self.FeedbackLinkBlob:addNewline()
        self.FeedbackLinkBlob:addTextWithoutNewline("Much appreciated!")

        self.MulticrewBlob = InlineButtonBlob:new()
        local multicrewState = vhfHelperMulticrewManager:getState()
        local maxStringWidth = 60

        local multicrewColor = Globals.Colors.white
        if (self.pendingMulticrewNotification) then
            multicrewColor = vhfHelperSideWindow.Constants.MulticrewStateToMessage[multicrewState][2]
        end

        self.MulticrewBlob:addColorTextWithoutNewline(
            vhfHelperSideWindow.Constants.MulticrewStateToMessage[multicrewState][1],
            multicrewColor
        )

        local lastMulticrewError = vhfHelperMulticrewManager:getLastErrorOrNil()
        if (lastMulticrewError ~= nil) then
            self.MulticrewBlob:addColorTextWithoutNewline(
                Utilities.newlineBreakStringAtWidth(lastMulticrewError, maxStringWidth),
                multicrewColor
            )
        end
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

    function vhfHelperSideWindow:isVisible()
        return self.window ~= nil
    end

    function vhfHelperSideWindow:bootstrap()
        self:_reset()
        Notifications.manager:postOnce(vhfHelperSideWindow.Notifications.HaveALookAtMe)
        if (VatsimData.isVatsimbriefHelperAvailable()) then
            Notifications.manager:postOnce(vhfHelperSideWindow.Notifications.VatsimDataAvailable)
        end
    end

    function vhfHelperSideWindow:areAnyNotificationsPending()
        if
            (Notifications.manager:isPending(vhfHelperSideWindow.Notifications.HaveALookAtMe) or
                Notifications.manager:isPending(vhfHelperSideWindow.Notifications.VatsimDataAvailable) or
                Notifications.manager:isPending(vhfHelperCompatibilityManager.Notifications.CompatibilityUpdate) or
                Notifications.manager:isPending(vhfHelperMulticrewManager.Notifications.StateChange))
         then
            return true
        end
        return false
    end

    function vhfHelperSideWindow:create()
        if (self.window ~= nil) then
            return
        end

        self:_reset()
        self:_createUiItems()

        local minWidthWithoutScrollbars = nil
        local minHeightWithoutScrollbars = nil

        globalFontScaleDescriptor = Utilities.trim(Config.Config:getValue("Windows", "GlobalFontScale", "big"))
        if (globalFontScaleDescriptor == "huge") then
            minWidthWithoutScrollbars = 300
            minHeightWithoutScrollbars = 300
        elseif (globalFontScaleDescriptor == "big") then
            minWidthWithoutScrollbars = 550
            minHeightWithoutScrollbars = 550
        else
            minWidthWithoutScrollbars = 100
            minHeightWithoutScrollbars = 100
        end

        self.window = float_wnd_create(minWidthWithoutScrollbars, minHeightWithoutScrollbars, 1, true)
        float_wnd_set_title(self.window, vhfHelperSideWindow.Constants.defaultWindowName)
        float_wnd_set_imgui_builder(self.window, "renderVhfHelperSideWindowToCanvas")
        float_wnd_set_onclose(self.window, "closeVhfHelperSideWindow")

        Globals.IssueWorkarounds.FlyWithLua.timeTagWindowCreatedNow(vhfHelperSideWindow)
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
        Globals.pushDefaultsToImguiStack()

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
        self.MulticrewBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Vatsim Data")
        self.VatsimDataBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Updates")
        self.UpdatesBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Plane Compatibility")
        self.PlaneCompatibilityBlob:renderToCanvas()

        imgui.TextUnformatted("")
        self:_renderSectionHeader("Feedback :-)")
        self.FeedbackLinkBlob:renderToCanvas()

        Globals.popDefaultsFromImguiStack()
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
