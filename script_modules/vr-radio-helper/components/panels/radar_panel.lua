local Globals = require("vr-radio-helper.globals")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local SubPanel = require("vr-radio-helper.components.panels.sub_panel")
local FlexibleLength1DSpring = require("vr-radio-helper.shared_components.flexible_length_1d_spring")
local FlexibleLength3DSpring = require("vr-radio-helper.shared_components.flexible_length_3d_spring")
local VatsimData = require("vr-radio-helper.state.vatsim_data")
local Datarefs = require("vr-radio-helper.state.datarefs")
local LuaPlatform = require("lua_platform")
local BlockingGrid = require("vr-radio-helper.components.panels.blocking_grid")

local RadarPanel
do
    RadarPanel = SubPanel:new()

    RadarPanel.Constants = {
        ClientType = {
            Plane = 0,
            Station = 1
        },
        HeadingMode = {
            North = "North",
            Heading = "Heading"
        },
        FollowMode = {
            Free = "Free",
            Follow = "Follow"
        },
        ImguiTopLeftPadding = 5,
        MaxZoomRange = 600.0,
        IconSize = 16,
        HalfIconSize = 8,
        VisibleIconSize = 10,
        VisibleHalfIconSize = 5,
        BlockingGridAggregationFrames = 30
    }
    TRACK_ISSUE(
        "Imgui",
        "Imgui does not start rendering at 0/0, but instead at 5/5.",
        "Move everything down and right a bit via padding."
    )

    Globals.OVERRIDE(RadarPanel.new)
    function RadarPanel:new(newPanelTitle)
        local newInstanceWithState = SubPanel:new(newPanelTitle)

        setmetatable(newInstanceWithState, self)
        self.__index = self

        self.planeIcon = float_wnd_load_image(SCRIPT_DIRECTORY .. "vr_radio_helper_data/radar_plane.png")
        assert(self.planeIcon)

        self.stationIcon = float_wnd_load_image(SCRIPT_DIRECTORY .. "vr_radio_helper_data/radar_station.png")
        assert(self.stationIcon)

        self.whiteImage = float_wnd_load_image(SCRIPT_DIRECTORY .. "vr_radio_helper_data/white.png")
        assert(self.stationIcon)

        self.currentHeadingMode = RadarPanel.Constants.HeadingMode.Heading
        self.currentFollowMode = RadarPanel.Constants.FollowMode.Follow

        self.headingSpring = FlexibleLength1DSpring:new(100, 0.2)
        self.zoomSpring = FlexibleLength1DSpring:new(100, 0.2)
        self.zoomRange = RadarPanel.Constants.MaxZoomRange
        self.zoomSpring:setTarget(self.zoomRange * 100.0)
        self.zoomSpring:overrideCurrentPosition(self.zoomRange * 100.0)

        self.worldViewPosSpring = FlexibleLength3DSpring:new(100, 0.2)

        self.vatsimClients = nil
        self.renderClients = {}
        self.indexedRenderClients = {}
        self.newVatsimClientsUpdateAvailable = false

        self.realScreenWidth = 254
        self.realScreenHeight = 308
        self.screenWidth = 254 - RadarPanel.Constants.ImguiTopLeftPadding
        self.screenHeight = 308 - RadarPanel.Constants.ImguiTopLeftPadding

        self.currentBlockingClientOffset = 0
        self.blockingGrid =
            BlockingGrid:new(self.screenWidth, self.screenHeight, RadarPanel.Constants.BlockingGridAggregationFrames)

        self.rotationMatrixCache = {}
        self.rotatedQuadCache = {}

        self.bubbleSortIndex = 1

        return newInstanceWithState
    end

    local Matrix2x2
    do
        Matrix2x2 = {}

        function Matrix2x2:new(v11, v12, v21, v22)
            local newInstanceWithState = {
                v11,
                v12,
                v21,
                v22
            }
            setmetatable(newInstanceWithState, self)
            self.__index = self
            return newInstanceWithState
        end

        function Matrix2x2:newRotationMatrix(rotationAngle)
            return Matrix2x2:new(
                math.cos(rotationAngle),
                -math.sin(rotationAngle),
                math.sin(rotationAngle),
                math.cos(rotationAngle)
            )
        end

        function Matrix2x2:multiplyVector2(multiplyV)
            return {
                self[1] * multiplyV[1] + self[2] * multiplyV[2],
                self[3] * multiplyV[1] + self[4] * multiplyV[2]
            }
        end
    end

    local function vector2Substract(v, minusV)
        return {v[1] - minusV[1], v[2] - minusV[2]}
    end

    local function vector2Add(v, plusV)
        return {v[1] + plusV[1], v[2] + plusV[2]}
    end

    local function vector2Length(v)
        return math.sqrt(v[1] * v[1] + v[2] * v[2])
    end

    local function vector2Scale(v, scale)
        return {v[1] * scale, v[2] * scale}
    end

    function RadarPanel:_getRotationMatrixFromCache(rotationAngleRad)
        local degFloored = math.floor(rotationAngleRad * Utilities.RadToDeg)
        if (self.rotationMatrixCache[degFloored] == nil) then
            self.rotationMatrixCache[degFloored] = Matrix2x2:newRotationMatrix(rotationAngleRad)
        end

        return self.rotationMatrixCache[degFloored]
    end

    function RadarPanel:_worldToCameraSpace(worldPos)
        local translated = vector2Substract(worldPos, self.worldViewPosition)
        local rotated = self.rotationMatrix:multiplyVector2(translated)
        return rotated
    end

    function RadarPanel:_cameraToClipSpace(cameraPos)
        return self.clipToScreenMatrix:multiplyVector2(cameraPos)
    end

    function RadarPanel:_clipToScreenSpace(clipPos)
        return {
            math.floor((clipPos[1] + 0.5) * self.screenWidth),
            math.floor((1.0 - (clipPos[2] + 0.5)) * self.screenHeight)
        }
    end

    function RadarPanel:_isVisible(clipPos)
        local clipMax = 0.5
        if (clipPos[1] > clipMax or clipPos[1] < -clipMax or clipPos[2] > clipMax or clipPos[2] < -clipMax) then
            return false
        end
        return true
    end

    function RadarPanel:_precomputeFrameConstants(viewRotation, worldViewPosition)
        self.zoomRatio = nil

        local aspect = self.screenWidth / self.screenHeight
        local left, right, top, bottom = nil
        if (aspect >= 1.0) then
            left = -self.zoomSpring:getCurrentPosition()
            right = self.zoomSpring:getCurrentPosition()
            top = -self.zoomSpring:getCurrentPosition() * aspect
            bottom = self.zoomSpring:getCurrentPosition() * aspect
            zoomRatio = self.zoomSpring:getCurrentPosition() * 2.0 / self.screenWidth
        else
            top = -self.zoomSpring:getCurrentPosition()
            bottom = self.zoomSpring:getCurrentPosition()
            left = -self.zoomSpring:getCurrentPosition() * aspect
            right = self.zoomSpring:getCurrentPosition() * aspect
            zoomRatio = self.zoomSpring:getCurrentPosition() * 2.0 / self.screenHeight
        end

        self.oneOverZoomRatio = 1.0 / zoomRatio
        self.clipToScreenMatrix = Matrix2x2:new(1.0 / (right - left), 0.0, 0.0, 1.0 / (bottom - top))

        local rotationAngle = (viewRotation * Utilities.DegToRad) % Utilities.FullCircleRadians
        self.rotationMatrix = Matrix2x2:newRotationMatrix(rotationAngle)

        self.worldViewPosition = worldViewPosition
    end

    function RadarPanel:_setNewHeadingTarget(newTarget)
        local newTarget360 = newTarget + 360.0
        local currentTarget = self.headingSpring:getCurrentTargetPosition()
        local currentTarget360 = currentTarget + 360
        if (math.abs(currentTarget360 - newTarget) < math.abs(currentTarget - newTarget)) then
            self.headingSpring:overrideCurrentPosition(self.headingSpring:getCurrentPosition() + 360.0)
        elseif (math.abs(newTarget360 - currentTarget) < math.abs(newTarget - currentTarget)) then
            newTarget = newTarget + 360.0
        end
        self.headingSpring:setTarget(newTarget)
    end

    function RadarPanel:_convertVatsimLocationToFlat3DKm(latitude, longitude, altitude)
        local lonDiff = Datarefs.getCurrentLongitude() - longitude
        return {
            111.320 * longitude + lonDiff * math.cos(latitude * Utilities.DegToRad),
            110.574 * latitude,
            altitude * Utilities.FeetToMeter
        }
    end

    function RadarPanel:_getRenderClientForVatsimClient(vatsimClient)
        local clientType = nil
        if (vatsimClient.type == "Plane") then
            clientType = RadarPanel.Constants.ClientType.Plane
        elseif (vatsimClient.type == "Station") then
            clientType = RadarPanel.Constants.ClientType.Station
        end

        if
            (clientType ~= nil and vatsimClient.vatsimClientId ~= nil and vatsimClient.latitude ~= nil and
                vatsimClient.longitude ~= nil and
                (vatsimClient.callSign ~= nil or vatsimClient.id ~= nil))
         then
            local newWorldPos =
                self:_convertVatsimLocationToFlat3DKm(
                tonumber(vatsimClient.latitude),
                tonumber(vatsimClient.longitude),
                tonumber(vatsimClient.altitude) or 0.0
            )

            local newName = vatsimClient.callSign or vatsimClient.id
            local newHeading = 0.0
            if (vatsimClient.heading ~= nil) then
                newHeading = tonumber(vatsimClient.heading)
            end
            local newSpeed = 0.0
            if (vatsimClient.groundSpeed ~= nil) then
                newSpeed = tonumber(vatsimClient.groundSpeed) * Utilities.KnotsToKmh
            end

            return {
                type = clientType,
                vatsimClientId = vatsimClient.vatsimClientId,
                name = newName,
                worldPos = newWorldPos,
                worldHeading = newHeading,
                speed = newSpeed,
                frequency = vatsimClient.frequency
            }
        end

        return nil
    end

    function RadarPanel:_updateRenderClient(newRenderClient, freshTimestamp)
        local uniqueId = ("%s%s"):format(newRenderClient.vatsimClientId, newRenderClient.name)
        local oldClient = self.renderClients[uniqueId]
        self.renderClients[uniqueId] = newRenderClient
        local updatedRenderClient = self.renderClients[uniqueId]

        if (oldClient == nil) then
            updatedRenderClient.labelVisibility = 0.0
            updatedRenderClient.lastLabelBlockingValue = 1
            updatedRenderClient.isVisible = true
            updatedRenderClient.worldPosSpring = FlexibleLength3DSpring:new(100.0, 0.3)
            if (self.dataTimestamp ~= nil) then
                updatedRenderClient.firstSeenTimestamp = LuaPlatform.Time.now()
            else
                updatedRenderClient.firstSeenTimestamp = LuaPlatform.Time.now() - 70.0
            end
        else
            updatedRenderClient.lastUnblockedLabelOffset = oldClient.lastUnblockedLabelOffset
            updatedRenderClient.lastLabelBlockingValue = oldClient.lastLabelBlockingValue
            updatedRenderClient.labelVisibility = oldClient.labelVisibility
            updatedRenderClient.worldPosSpring = oldClient.worldPosSpring
            updatedRenderClient.firstSeenTimestamp = oldClient.firstSeenTimestamp
        end

        local headingRotation = self:_getRotationMatrixFromCache(-updatedRenderClient.worldHeading * Utilities.DegToRad)
        local velocity = {0.0, updatedRenderClient.speed * Utilities.KmhToMeterPerSecond}
        updatedRenderClient.velocity = headingRotation:multiplyVector2(velocity)

        updatedRenderClient.worldPosSpring:setTarget(updatedRenderClient.worldPos)
        updatedRenderClient.dataTimestamp = freshTimestamp
    end

    function RadarPanel:_refreshVatsimClientsNow()
        self.newVatsimClientsUpdateAvailable = false

        local vatsimClients, ownCallSign, timeStamp = VatsimData.getAllVatsimClientsWithOwnCallsignAndTimestamp()

        if (#vatsimClients > 0) then
            local num = 0
            local numValid = 0
            for _, vatsimClient in ipairs(vatsimClients) do
                if (vatsimClient.currentDistance > RadarPanel.Constants.MaxZoomRange) then
                    logMsg(
                        ("VR Radio Helper Radar: Stopping Vatsim data processing at client=%s distance=%.1fkm/%.1fnm num=%d/%d"):format(
                            vatsimClient.callSign or vatsimClient.id,
                            vatsimClient.currentDistance,
                            vatsimClient.currentDistance * Utilities.KmToNm,
                            num,
                            #vatsimClients
                        )
                    )

                    break
                end
                num = num + 1
                local newRenderClient = self:_getRenderClientForVatsimClient(vatsimClient)

                if (newRenderClient ~= nil) then
                    numValid = numValid + 1
                    self:_updateRenderClient(newRenderClient, timeStamp)
                end
            end

            self.dataTimestamp = timeStamp

            if (numValid ~= num) then
                logMsg(
                    ("VR Radio Helper Radar: Warning: Found invalid Vatsim clients (valid=%d/%d) in data, ignoring."):format(
                        numValid,
                        num
                    )
                )
            end
        end

        -- TODO: Maybe cleanup old render clients. It's a good feature having disconnected stations and/or planes still visible forever.

        TRACK_ISSUE(
            "Tech Debt / Optimization",
            MULTILINE_TEXT(
                "There are not too many airplanes within the maximum radar range usually (up to 400 at most),",
                "but finding your own callsign in this table can be made faster, i.e. O(1), maybe on Vatsimbrief Helper side."
            ),
            "Your own airplane is usually the first or one of the first in this list (because it's sorted by distance). Leave it for now."
        )

        self.ownClients = {}
        local ownClientCallSign = ownCallSign
        local ownClientObserverCallSign = ("%sA"):format(ownCallSign)
        local ownClientFound = false
        local ownObserverFound = false
        for _, client in ipairs(self.renderClients) do
            if (client.name == ownClientCallSign) then
                self.ownClients[client.name] = client
                self.ownClientFound = true
            end
            if (client.name == ownClientObserverCallSign) then
                self.ownClients[client.name] = client
                self.ownObserverFound = true
            end

            if (ownObserverFound and ownClientFound) then
                break
            end
        end

        self.indexedRenderClients = {}
        for cid, client in pairs(self.renderClients) do
            table.insert(self.indexedRenderClients, client)
        end
    end

    function RadarPanel:refreshVatsimClients()
        self.newVatsimClientsUpdateAvailable = true
    end

    function RadarPanel:_transformAndClipAllClients(viewHeading)
        local numVisible = 0
        for cid, client in pairs(self.renderClients) do
            local cameraPos = self:_worldToCameraSpace(client.worldPosSpring:getCurrentPosition())
            client.cameraHeading = client.worldHeading - viewHeading
            local clipPos = self:_cameraToClipSpace(cameraPos)

            if (self:_isVisible(clipPos)) then
                numVisible = numVisible + 1
                if (client.isVisible == false) then
                    client.labelVisibility = 0.0
                end
                client.isVisible = true
                client.screenPos = self:_clipToScreenSpace(clipPos)
            else
                client.isVisible = false
            end
        end
    end

    function RadarPanel:_renderAllClients()
        self.tunedInStationClients = {}
        self:_renderAllClientsIconBlockingPass()
        self:_renderAllPlanes()
        self:_renderAllStations()
        self:_renderAllTunedInStationClients()
    end

    function RadarPanel:_renderAllPlanes()
        for index, client in ipairs(self.indexedRenderClients) do
            if (client.isVisible and client.type == RadarPanel.Constants.ClientType.Plane) then
                self:_renderClient(client, index - 1)
            end
        end
    end

    function RadarPanel:_renderAllStations()
        for index, client in ipairs(self.indexedRenderClients) do
            if (client.isVisible and client.type == RadarPanel.Constants.ClientType.Station) then
                self:_renderClient(client, index - 1, true)
            end
        end
    end

    function RadarPanel:_renderAllTunedInStationClients()
        for manualIndex, client in pairs(self.tunedInStationClients) do
            if (client.isVisible) then
                self:_renderClient(client, manualIndex)
            end
        end
    end

    function RadarPanel:_renderAllClientsIconBlockingPass()
        for index, client in ipairs(self.indexedRenderClients) do
            if (client.isVisible) then
                self:_renderClientIconBlockingPass(client, index - 1)
            end
        end
    end

    Globals.OVERRIDE(RadarPanel.loop)
    function RadarPanel:loop(frameTime)
        self.frameTime = frameTime
        SubPanel.loop(self, frameTime)
        if (self.newVatsimClientsUpdateAvailable) then
            self:_refreshVatsimClientsNow()
        end

        for cid, renderClient in pairs(self.renderClients) do
            renderClient.worldPosSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        end

        self.headingSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        self.zoomSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        self.worldViewPosSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)

        self:_extrapolatePlanes()
    end

    function RadarPanel:_extrapolatePlanes()
        local now = LuaPlatform.Time.now()
        for cid, client in pairs(self.renderClients) do
            if (client.type == RadarPanel.Constants.ClientType.Plane) then
                local extrapolatedWorldPos =
                    vector2Add(
                    client.worldPos,
                    vector2Scale(client.velocity, math.min(70.0, now - client.dataTimestamp))
                )
                client.worldPosSpring:setTarget({extrapolatedWorldPos[1], extrapolatedWorldPos[2], 0.0})
            end
        end
    end

    function RadarPanel:_bubbleSortClientsByAltitude()
        if (self.bubbleSortIndex >= #self.indexedRenderClients) then
            self.bubbleSortIndex = 1
        end

        if (#self.indexedRenderClients < 2) then
            return
        end

        local swapped = false
        if
            (self.indexedRenderClients[self.bubbleSortIndex + 1].worldPos[3] <
                self.indexedRenderClients[self.bubbleSortIndex].worldPos[3])
         then
            swapped = true
            local swapClient = self.indexedRenderClients[self.bubbleSortIndex]
            self.indexedRenderClients[self.bubbleSortIndex] = self.indexedRenderClients[self.bubbleSortIndex + 1]
            self.indexedRenderClients[self.bubbleSortIndex + 1] = swapClient
        end

        self.bubbleSortIndex = self.bubbleSortIndex + 1
        return swapped
    end

    Globals.OVERRIDE(RadarPanel.renderToCanvas)
    function RadarPanel:renderToCanvas()
        imgui.SetWindowFontScale(1.0)
        self.blockingGrid:coolDown()

        self.zoomSpring:setTarget(self.zoomRange)

        if (self.currentHeadingMode == RadarPanel.Constants.HeadingMode.Heading) then
            if (self.currentFollowMode == RadarPanel.Constants.FollowMode.Follow) then
                self:_setNewHeadingTarget(Datarefs.getCurrentHeading())
            end
        else
            self:_setNewHeadingTarget(0.0)
        end

        local viewHeading = self.headingSpring:getCurrentPosition() % 360.0

        self.ownWorldPos =
            self:_convertVatsimLocationToFlat3DKm(
            Datarefs.getCurrentLatitude(),
            Datarefs.getCurrentLongitude(),
            Datarefs.getCurrentAltitude() * Utilities.MeterToFeet
        )

        if (self.currentFollowMode == RadarPanel.Constants.FollowMode.Follow) then
            self.worldViewPosSpring:setTarget(self.ownWorldPos)
        end

        local worldViewPos = self.worldViewPosSpring:getCurrentPosition()

        self:_precomputeFrameConstants(viewHeading, {worldViewPos[1], worldViewPos[2]})

        local ownScreenPos = self:_worldToCameraSpace(self.ownWorldPos)
        ownScreenPos = self:_cameraToClipSpace(ownScreenPos)
        ownScreenPos = self:_clipToScreenSpace(ownScreenPos)

        self:_transformAndClipAllClients(viewHeading)

        imgui.PushClipRect(0, 0, self.realScreenWidth, self.realScreenHeight, true)

        self:_renderDistanceCircles(self.ownWorldPos, ownScreenPos, worldViewPos, viewHeading)
        self:_renderCompass()
        self:_renderHeadingLine(ownScreenPos, self.ownWorldPos, Datarefs.getCurrentHeading())

        self:_renderAllClients()
        self:_renderOwnMarker(ownScreenPos, Datarefs.getCurrentHeading(), viewHeading)

        -- self:_debugRenderBlockingGrid()

        imgui.PopClipRect()

        self:_renderControlButtons(viewHeading)
        self:_renderTimestamp()

        local numPercentageOfClients = math.max(1, math.floor(#self.indexedRenderClients * 0.5))
        for i = 1, numPercentageOfClients do
            self:_bubbleSortClientsByAltitude()
        end

        imgui.SetCursorPos(0.0, 309.0)

        self.currentBlockingClientOffset = self.currentBlockingClientOffset + 1
        if (self.currentBlockingClientOffset >= self.blockingGrid.heatUpFrames) then
            self.currentBlockingClientOffset = 0
        end
    end

    function RadarPanel:_renderTimestamp()
        imgui.SetCursorPos(RadarPanel.Constants.ImguiTopLeftPadding, 290)

        if (self.dataTimestamp == nil) then
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
            imgui.TextUnformatted("No data")
            imgui.PopStyleColor()
        else
            local now = LuaPlatform.Time.now()
            local diff = now - self.dataTimestamp
            local diffStr = nil
            if (diff > 70.0) then
                diffStr = ("%dm ago"):format(math.floor(diff / 60.0))
            elseif (diff > 10.0) then
                local roundedDiff = math.floor(diff / 10.0) * 10.0
                diffStr = ("%ds ago"):format(roundedDiff)
            else
                diffStr = "now"
            end

            local color = Globals.Colors.white
            if (diff > 130.0) then
                color = Globals.Colors.a320Red
            elseif (diff > 70.0) then
                color = Globals.Colors.a320Orange
            else
                color = Globals.Colors.greyText
            end

            imgui.PushStyleColor(imgui.constant.Col.Text, color)
            imgui.TextUnformatted(("Updated %s"):format(diffStr))
            imgui.PopStyleColor()
        end
    end

    function RadarPanel:_renderHeadingLine(ownScreenPos, ownWorldPos, ownWorldHeading)
        local upAheadPoint = {0.0, self.zoomSpring:getCurrentPosition() * 0.5}
        local headingRotation = self:_getRotationMatrixFromCache(-ownWorldHeading * Utilities.DegToRad)
        local headingPoint = headingRotation:multiplyVector2(upAheadPoint)
        headingPoint = vector2Add(ownWorldPos, headingPoint)

        headingPoint = self:_worldToCameraSpace(headingPoint)
        headingPoint = self:_cameraToClipSpace(headingPoint)
        headingPoint = self:_clipToScreenSpace(headingPoint)

        headingPoint =
            vector2Add(
            headingPoint,
            {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding}
        )

        imgui.DrawList_AddLine(
            ownScreenPos[1] + RadarPanel.Constants.ImguiTopLeftPadding,
            ownScreenPos[2] + RadarPanel.Constants.ImguiTopLeftPadding,
            headingPoint[1],
            headingPoint[2],
            0xFF003355,
            2.0
        )
    end

    function RadarPanel:_renderOwnMarker(ownScreenPos, ownWorldHeading, viewHeading)
        self:_renderIconToBlockingGrid(ownScreenPos, 0)
        self:_renderImageQuad(
            self.planeIcon,
            RadarPanel.Constants.HalfIconSize,
            ownScreenPos,
            ownWorldHeading - viewHeading,
            Globals.Colors.a320Orange
        )
    end

    function RadarPanel:_zoomIn()
        if (self.zoomRange > 0.146484375) then
            self.zoomRange = self.zoomRange * 0.5
        end
    end

    function RadarPanel:_zoomOut()
        if (self.zoomRange < RadarPanel.Constants.MaxZoomRange) then
            self.zoomRange = self.zoomRange * 2.0
        end
    end

    function RadarPanel:_renderControlButtons(viewHeading)
        imgui.SetCursorPos(RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding)
        imgui.PushStyleColor(imgui.constant.Col.Button, Globals.Colors.defaultImguiButtonBackground)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Globals.Colors.defaultImguiButtonBackground)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, Globals.Colors.slightlyBrighterDefaultButtonColor)

        if (imgui.Button("-")) then
            self:_zoomOut()
        end

        imgui.SameLine()
        if (imgui.Button("+")) then
            self:_zoomIn()
        end

        imgui.SameLine()
        local modeButtonText = nil
        if (self.currentHeadingMode == RadarPanel.Constants.HeadingMode.Heading) then
            modeButtonText = "North"
        else
            modeButtonText = "Headg"
        end

        if (imgui.Button(modeButtonText)) then
            if (self.currentHeadingMode == RadarPanel.Constants.HeadingMode.Heading) then
                self.currentHeadingMode = RadarPanel.Constants.HeadingMode.North
            else
                self.currentHeadingMode = RadarPanel.Constants.HeadingMode.Heading
                if (self.currentFollowMode == RadarPanel.Constants.FollowMode.Free) then
                    self:_setNewHeadingTarget(Datarefs.getCurrentHeading())
                end
            end
        end

        imgui.SameLine()
        Globals.ImguiUtils.renderActiveInactiveButton(
            "Follow",
            self.currentFollowMode == RadarPanel.Constants.FollowMode.Follow,
            true,
            function(buttonTitle)
                self.currentFollowMode = RadarPanel.Constants.FollowMode.Follow
            end
        )

        local panRange = 0.3 * self.zoomRange
        local panVector = {0.0, 0.0}

        local panButtonSize = math.min(self.screenWidth, self.screenHeight) * 0.33
        local halfPanButtonSize = panButtonSize * 0.5

        local centerPoint = {
            self.screenWidth * 0.5 + RadarPanel.Constants.ImguiTopLeftPadding,
            self.screenHeight * 0.5 + RadarPanel.Constants.ImguiTopLeftPadding
        }

        imgui.PushStyleColor(imgui.constant.Col.Text, 0x00444444)
        imgui.PushStyleColor(imgui.constant.Col.Button, 0x00222222)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, 0x00222222)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, 0x00222222)

        imgui.SetCursorPos(centerPoint[1] - 3.0 * halfPanButtonSize, centerPoint[2] - 3.0 * halfPanButtonSize)
        if (imgui.Button("UL", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] + panRange
            panVector[1] = panVector[1] - panRange
        end

        imgui.SetCursorPos(centerPoint[1] - halfPanButtonSize, centerPoint[2] - 3.0 * halfPanButtonSize)
        if (imgui.Button("U", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] + panRange
        end

        imgui.SetCursorPos(centerPoint[1] + halfPanButtonSize, centerPoint[2] - 3.0 * halfPanButtonSize)
        if (imgui.Button("UR", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] + panRange
            panVector[1] = panVector[1] + panRange
        end

        imgui.SetCursorPos(centerPoint[1] - 3.0 * halfPanButtonSize, centerPoint[2] - halfPanButtonSize)
        if (imgui.Button("L", panButtonSize, panButtonSize)) then
            panVector[1] = panVector[1] - panRange
        end

        imgui.SetCursorPos(centerPoint[1] - halfPanButtonSize, centerPoint[2] - halfPanButtonSize)
        if (imgui.Button("ZoomIn", panButtonSize, panButtonSize)) then
            self:_zoomIn()
        end

        imgui.SetCursorPos(centerPoint[1] + halfPanButtonSize, centerPoint[2] - halfPanButtonSize)
        if (imgui.Button("R", panButtonSize, panButtonSize)) then
            panVector[1] = panVector[1] + panRange
        end

        imgui.SetCursorPos(centerPoint[1] - 3.0 * halfPanButtonSize, centerPoint[2] + halfPanButtonSize)
        if (imgui.Button("DL", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] - panRange
            panVector[1] = panVector[1] - panRange
        end

        imgui.SetCursorPos(centerPoint[1] - halfPanButtonSize, centerPoint[2] + halfPanButtonSize)
        if (imgui.Button("D", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] - panRange
        end

        imgui.SetCursorPos(centerPoint[1] + halfPanButtonSize, centerPoint[2] + halfPanButtonSize)
        if (imgui.Button("DR", panButtonSize, panButtonSize)) then
            panVector[2] = panVector[2] - panRange
            panVector[1] = panVector[1] + panRange
        end

        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()

        if (panVector[1] ~= 0.0 or panVector[2] ~= 0.0) then
            self.currentFollowMode = RadarPanel.Constants.FollowMode.Free

            local panRotation = self:_getRotationMatrixFromCache((360.0 - viewHeading) * Utilities.DegToRad)
            panVector = panRotation:multiplyVector2(panVector)

            local currentWorldViewTarget = Vector3:newFromVector3(self.worldViewPosSpring:getCurrentTargetPosition())
            currentWorldViewTarget[1] = currentWorldViewTarget[1] + panVector[1]
            currentWorldViewTarget[2] = currentWorldViewTarget[2] + panVector[2]
            self.worldViewPosSpring:setTarget(currentWorldViewTarget)
        end

        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end

    function RadarPanel:_emptyIconInBlockingGrid(screenPos, clientIndex)
        if ((self.currentBlockingClientOffset + clientIndex) % self.blockingGrid.heatUpFrames ~= 0) then
            return
        end

        self.blockingGrid:emptyAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:emptyAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:emptyAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:emptyAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
    end

    function RadarPanel:_renderIconToBlockingGrid(screenPos, clientIndex)
        if ((self.currentBlockingClientOffset + clientIndex) % self.blockingGrid.heatUpFrames ~= 0) then
            return
        end

        self.blockingGrid:fillAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:fillAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:fillAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
        self.blockingGrid:fillAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.VisibleHalfIconSize,
                screenPos[2] + RadarPanel.Constants.VisibleIconSize - RadarPanel.Constants.VisibleHalfIconSize
            }
        )
    end

    function RadarPanel:_tryRenderingTextToBlockingGrid(screenPos, textLen)
        local startPos = self.blockingGrid:map(screenPos)
        local blockage = 0
        local startX = startPos[1]
        local startY = startPos[2]
        local maxX = startX
        local maxY = startY
        for t = 1, textLen do
            local currentCharacterPos = nil
            local gridPos = nil

            currentCharacterPos = {screenPos[1] + t * 7, screenPos[2]}
            gridPos = self.blockingGrid:map(currentCharacterPos)
            maxX = math.max(maxX, gridPos[1])
            blockage = blockage + self.blockingGrid:getValue(gridPos)

            -- self:_renderDebugPixels(currentCharacterPos, 1, 1, 0xFF00FFFF)

            currentCharacterPos = {screenPos[1] + t * 7, screenPos[2] + 9}
            gridPos = self.blockingGrid:map(currentCharacterPos)
            maxY = math.max(maxY, gridPos[2])
            blockage = blockage + self.blockingGrid:getValue(gridPos)

            -- self:_renderDebugPixels(currentCharacterPos, 1, 1, 0xFF00FFFF)
        end

        if (blockage == 0) then
            for y = startY, maxY do
                for x = startX, maxX do
                    self.blockingGrid:fill({x, y})
                end
            end
        end

        return blockage
    end

    function RadarPanel:_renderLabelToBlockingGrid(client, textLen, clientIndex)
        if ((self.currentBlockingClientOffset + clientIndex) % self.blockingGrid.heatUpFrames ~= 0) then
            return client.lastLabelBlockingValue
        end

        local xTextOffset = math.floor(-textLen * 3.5 + RadarPanel.Constants.HalfIconSize)
        local labelBelowOffset = {xTextOffset - 12, 7}

        local blockage = nil
        local unblockedOffset = nil

        blockage = self:_tryRenderingTextToBlockingGrid(vector2Add(client.screenPos, labelBelowOffset), textLen)
        if (blockage <= 0) then
            unblockedOffset = labelBelowOffset
        end

        client.lastLabelBlockingValue = blockage
        if (unblockedOffset ~= nil) then
            client.lastUnblockedLabelOffset = unblockedOffset
        end

        return blockage
    end

    function RadarPanel:_renderDistanceCircles(ownWorldPos, ownScreenPos, worldViewPos, heading)
        local diffVec = vector2Substract(worldViewPos, ownWorldPos)
        local d = vector2Length(diffVec)

        local textAngle = nil
        if (d < 0.1) then
            textAngle = (-45 - heading) * Utilities.DegToRad
        else
            local diffAngle = math.atan2(diffVec[2], diffVec[1])
            textAngle = diffAngle - (90.0 * Utilities.DegToRad)
        end

        local currentCircleNm = 0.078125
        local circleRotation = Matrix2x2:newRotationMatrix(textAngle)
        for c = 1, 13 do
            local circleKm = currentCircleNm * Utilities.NmToKm

            local circlePoint = {0.0, circleKm * 1.0}
            circlePoint = circleRotation:multiplyVector2(circlePoint)
            circlePoint = vector2Add(ownWorldPos, circlePoint)

            circlePoint = self:_worldToCameraSpace(circlePoint)
            circlePoint = self:_cameraToClipSpace(circlePoint)
            local circleStr = nil
            local renderDistanceText = false
            if (self:_isVisible(circlePoint)) then
                renderDistanceText = true
                circlePoint = self:_clipToScreenSpace(circlePoint)

                circlePoint =
                    vector2Add(
                    circlePoint,
                    {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding}
                )

                if (currentCircleNm <= 2.5) then
                    circleStr = ("%.2f"):format(currentCircleNm)
                else
                    circleStr = ("%.0f"):format(currentCircleNm)
                end
                imgui.SetCursorPos(
                    math.floor(circlePoint[1] - (circleStr:len() * 2.7)) - 5,
                    math.floor(circlePoint[2] - 8)
                )
            end

            local circleAlpha =
                math.min(255.0, Utilities.Math.lerp(0, 255.0, circleKm / self.zoomSpring:getCurrentPosition()))
            local circleColor = 0x00222222
            circleColor = Utilities.Color.setAlpha(circleColor, circleAlpha)

            imgui.DrawList_AddCircle(
                ownScreenPos[1] + RadarPanel.Constants.ImguiTopLeftPadding,
                ownScreenPos[2] + RadarPanel.Constants.ImguiTopLeftPadding,
                circleKm * self.oneOverZoomRatio,
                circleColor,
                36,
                math.max(2.0, currentCircleNm * 0.1)
            )

            if (renderDistanceText) then
                local circleTextColor = 0x00CCCCCC
                circleTextColor = Utilities.Color.setAlpha(circleTextColor, circleAlpha)
                imgui.PushStyleColor(imgui.constant.Col.Text, circleTextColor)
                imgui.TextUnformatted(circleStr)
                imgui.PopStyleColor()
            end

            currentCircleNm = currentCircleNm * 2.0
        end
    end

    function RadarPanel:_renderCompass()
        local northPoint = {0.0, self.zoomSpring:getCurrentPosition() * 0.75}
        local a = 0
        while a < 12 do
            local n = a * 30
            local compassRotation = self:_getRotationMatrixFromCache(-n * Utilities.DegToRad)
            local compassPoint = compassRotation:multiplyVector2(northPoint)
            compassPoint = vector2Add(self.worldViewPosition, compassPoint)

            compassPoint = self:_worldToCameraSpace(compassPoint)
            compassPoint = self:_cameraToClipSpace(compassPoint)
            compassPoint = self:_clipToScreenSpace(compassPoint)

            compassPoint =
                vector2Add(
                compassPoint,
                {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding}
            )

            local compassStr = tostring(math.floor(n * 0.1))
            imgui.SetCursorPos(math.floor(compassPoint[1]) - (compassStr:len() * 2.7), math.floor(compassPoint[2] - 8))
            local compassColor = Globals.Colors.darkerOrange

            if (n == 0) then
                imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
                imgui.TextUnformatted("N")
            else
                imgui.PushStyleColor(imgui.constant.Col.Text, compassColor)
                imgui.TextUnformatted(("%s"):format(compassStr))
            end
            imgui.PopStyleColor()

            a = a + 1
        end
    end

    function RadarPanel:_renderClientIconBlockingPass(client, clientIndex)
        self:_renderIconToBlockingGrid(client.screenPos, clientIndex)
    end

    function RadarPanel:_renderClient(client, clientIndex, collectTunedInStations)
        local icon = nil
        local color = Globals.Colors.white
        local isOwnClient = false
        local isOwnObserverClient = false

        if (self.ownClients[client.name] ~= nil) then
            isOwnClient = true
        end

        if (client.type == RadarPanel.Constants.ClientType.Plane) then
            icon = self.planeIcon
        else
            if (VHFHelperPublicInterface.isCurrentlyTunedIn(client.frequency)) then
                color = Globals.Colors.a320Orange
                if (collectTunedInStations == true) then
                    self.tunedInStationClients[clientIndex] = client
                    return
                end
            end
            if (isOwnClient) then
                isOwnObserverClient = true
            end
            icon = self.stationIcon
        end

        if (not isOwnObserverClient) then
            self:_emptyIconInBlockingGrid(client.screenPos, clientIndex)
        end

        if (client.dataTimestamp < self.dataTimestamp) then
            local darkerA320Red = 0xFF222288
            color = darkerA320Red
        end

        if (LuaPlatform.Time.now() - client.firstSeenTimestamp < 60.0) then
            color = Globals.Colors.a320Green
        end

        if
            (client.type == RadarPanel.Constants.ClientType.Plane and color ~= Globals.Colors.a320Green and
                color ~= Globals.Colors.darkerOrange)
         then
            -- 0xFF7FC3FF,
            if (client.worldPos[3] > self.ownWorldPos[3]) then
                color =
                    Utilities.lerpColors(
                    Globals.Colors.white,
                    Globals.Colors.a320Blue,
                    math.min(
                        1.0,
                        math.abs(client.worldPos[3] - self.ownWorldPos[3]) * (1.0 / (10000.0 * Utilities.FeetToMeter))
                    )
                )
            else
                color =
                    Utilities.lerpColors(
                    Globals.Colors.white,
                    Globals.Colors.darkerBlue,
                    math.min(
                        1.0,
                        math.abs(client.worldPos[3] - self.ownWorldPos[3]) * (1.0 / (10000.0 * Utilities.FeetToMeter))
                    )
                )
            end
        end

        if (not isOwnClient) then
            local textLen = client.name:len()
            local blockage = self:_renderLabelToBlockingGrid(client, textLen, clientIndex)

            local visibilityChangeSpeed = 0.5
            if (blockage <= 0) then
                client.labelVisibility =
                    math.min(1.0, client.labelVisibility + visibilityChangeSpeed * self.frameTime.cappedDt)
            else
                client.labelVisibility =
                    math.max(0.0, client.labelVisibility - visibilityChangeSpeed * self.frameTime.cappedDt)
            end

            if (client.labelVisibility > 0.25 and client.lastUnblockedLabelOffset ~= nil) then
                local textPosOffset = {9, 3}
                imgui.SetCursorPos(
                    client.screenPos[1] + client.lastUnblockedLabelOffset[1] + textPosOffset[1],
                    client.screenPos[2] + client.lastUnblockedLabelOffset[2] + textPosOffset[2]
                )

                local actualColor =
                    Utilities.lerpColors(0x00AAAAAA, color, math.min(1.0, (client.labelVisibility - 0.25) * 2.0))
                imgui.PushStyleColor(imgui.constant.Col.Text, actualColor)
                imgui.TextUnformatted(client.name)
                imgui.PopStyleColor()
            end
        end

        if (isOwnClient and client.dataTimestamp == self.dataTimestamp) then
            color = Globals.Colors.darkerOrange
        end

        if (not isOwnObserverClient) then
            self:_renderImageQuad(
                icon,
                RadarPanel.Constants.HalfIconSize,
                client.screenPos,
                client.cameraHeading,
                color
            )

            self:_renderIconToBlockingGrid(client.screenPos, clientIndex)
        end
    end

    function RadarPanel:_getRotatedQuadFromCache(rotationAngleDeg)
        local cachedRotationAngle = math.floor(rotationAngleDeg)

        if (self.rotatedQuadCache[cachedRotationAngle] ~= nil) then
            return self.rotatedQuadCache[cachedRotationAngle]
        end

        local leftTopPos = {-RadarPanel.Constants.HalfIconSize, -RadarPanel.Constants.HalfIconSize}
        local rightTopPos = {RadarPanel.Constants.HalfIconSize, -RadarPanel.Constants.HalfIconSize}
        local rightBottomPos = {RadarPanel.Constants.HalfIconSize, RadarPanel.Constants.HalfIconSize}
        local leftBottomPos = {-RadarPanel.Constants.HalfIconSize, RadarPanel.Constants.HalfIconSize}

        local rotationAngle = (rotationAngleDeg * Utilities.DegToRad) % Utilities.FullCircleRadians
        local rotationMatrix = self:_getRotationMatrixFromCache(rotationAngle)

        leftTopPos = rotationMatrix:multiplyVector2(leftTopPos)
        rightTopPos = rotationMatrix:multiplyVector2(rightTopPos)
        rightBottomPos = rotationMatrix:multiplyVector2(rightBottomPos)
        leftBottomPos = rotationMatrix:multiplyVector2(leftBottomPos)

        self.rotatedQuadCache[cachedRotationAngle] = {leftTopPos, rightTopPos, rightBottomPos, leftBottomPos}

        return self.rotatedQuadCache[cachedRotationAngle]
    end

    function RadarPanel:_renderImageQuad(imageId, imageHalfSize, screenPos, rotation, color)
        local positions = self:_getRotatedQuadFromCache(rotation)
        local paddingVec =
            vector2Add(screenPos, {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding})
        leftTopPos = vector2Add(positions[1], paddingVec)
        rightTopPos = vector2Add(positions[2], paddingVec)
        rightBottomPos = vector2Add(positions[3], paddingVec)
        leftBottomPos = vector2Add(positions[4], paddingVec)

        imgui.DrawList_AddImageQuad(
            imageId,
            leftTopPos[1],
            leftTopPos[2],
            rightTopPos[1],
            rightTopPos[2],
            rightBottomPos[1],
            rightBottomPos[2],
            leftBottomPos[1],
            leftBottomPos[2],
            0,
            0,
            1,
            0,
            1,
            1,
            0,
            1,
            color
        )
    end

    function RadarPanel:_debugRenderBlockingGrid()
        for y = 1, self.blockingGrid.len do
            for x = 1, self.blockingGrid.len do
                local v = self.blockingGrid.grid[y * self.blockingGrid.len + x]
                local color =
                    Utilities.lerpColors(
                    0x2200FF00,
                    0x220000FF,
                    Utilities.Math.lerp(0.0, 1.0, math.min(1.0, v / self.blockingGrid.heatUpFrames))
                )

                if (v <= 0) then
                    color = 0x22FF0000
                end
                Globals.ImguiUtils.renderDebugPixels(
                    self.whiteImage,
                    {
                        ((x - 1) * self.screenWidth) / self.blockingGrid.len,
                        ((y - 1) * self.screenHeight) / self.blockingGrid.len
                    },
                    self.screenWidth / self.blockingGrid.len,
                    self.screenHeight / self.blockingGrid.len,
                    color
                )
            end
        end
    end

    function RadarPanel:_renderDebugPixels(screenPos, rectWidth, rectHeight, color)
        local actualScreenPos = {
            screenPos[1] + RadarPanel.Constants.ImguiTopLeftPadding,
            screenPos[2] + RadarPanel.Constants.ImguiTopLeftPadding
        }
        imgui.DrawList_AddImageQuad(
            self.whiteImage,
            actualScreenPos[1],
            actualScreenPos[2],
            actualScreenPos[1] + rectWidth,
            actualScreenPos[2],
            actualScreenPos[1] + rectWidth,
            actualScreenPos[2] + rectHeight,
            actualScreenPos[1],
            actualScreenPos[2] + rectHeight,
            0,
            0,
            1,
            0,
            1,
            1,
            0,
            1,
            color
        )
    end
end

return RadarPanel
