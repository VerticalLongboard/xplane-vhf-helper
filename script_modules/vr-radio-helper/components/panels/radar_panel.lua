local Globals = require("vr-radio-helper.globals")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local SubPanel = require("vr-radio-helper.components.panels.sub_panel")
local FlexibleLength1DSpring = require("vr-radio-helper.shared_components.flexible_length_1d_spring")
local FlexibleLength3DSpring = require("vr-radio-helper.shared_components.flexible_length_3d_spring")
local VatsimData = require("vr-radio-helper.state.vatsim_data")
local Datarefs = require("vr-radio-helper.state.datarefs")
local LuaPlatform = require("lua_platform")

local RadarPanel
do
    RadarPanel = SubPanel:new()

    RadarPanel.Constants = {
        ClientType = {
            Plane = "client",
            Station = "Station"
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
        IconSize = 10,
        HalfIconSize = 5
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
        self.zoomSpring:setTarget(self.zoomRange)
        self.worldViewPosSpring = FlexibleLength3DSpring:new(100, 0.2)

        self.vatsimClients = nil
        self.renderClients = {}
        self.totalVatsimClients = 0
        self.newVatsimClientsUpdateAvailable = false

        self.realScreenWidth = 254
        self.realScreenHeight = 308
        self.screenWidth = 254 - RadarPanel.Constants.ImguiTopLeftPadding
        self.screenHeight = 308 - RadarPanel.Constants.ImguiTopLeftPadding

        self.DEBUG_BLOCKING_GRID = function(f)
            f()
        end

        return newInstanceWithState
    end

    function RadarPanel:_convertVatsimLocationToFlat3DKm(latitude, longitude, altitude)
        return {
            111.320 * longitude * math.cos(latitude * Utilities.DegToRad),
            110.574 * latitude,
            altitude * Utilities.FeetToM
        }
    end

    function RadarPanel:_convertVatsimClientsToRenderClients(vatsimclientTable)
        local clients = {}
        if (vatsimclientTable == nil) then
            return clients
        end

        local num = 0
        for _, vatsimClient in ipairs(vatsimclientTable) do
            if (vatsimClient.currentDistance > RadarPanel.Constants.MaxZoomRange) then
                logMsg(
                    ("VR Radio Helper Radar: Stopping Vatsim data processing at client=%s distance=%.1fkm/%.1fnm num=%d/%d"):format(
                        vatsimClient.callSign or vatsimClient.id,
                        vatsimClient.currentDistance,
                        vatsimClient.currentDistance * Utilities.KmToNm,
                        num,
                        #vatsimclientTable
                    )
                )

                break
            end
            num = num + 1
            local clientType = nil
            if (vatsimClient.type == "Plane") then
                clientType = RadarPanel.Constants.ClientType.Plane
            elseif (vatsimClient.type == "Station") then
                clientType = RadarPanel.Constants.ClientType.Station
            end

            if (clientType ~= nil) then
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

                table.insert(
                    clients,
                    {
                        type = clientType,
                        name = newName,
                        worldPos = newWorldPos,
                        worldHeading = newHeading,
                        speed = newSpeed,
                        frequency = vatsimClient.frequency,
                        labelVisibility = 0.0
                    }
                )
            end
        end

        return clients
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

    local function vector3Scale(v, scale)
        return {v[1] * scale, v[2] * scale}
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

    function RadarPanel:_refreshVatsimClientsNow()
        if (not self.newVatsimClientsUpdateAvailable) then
            return
        end

        self.newVatsimClientsUpdateAvailable = false

        local vatsimClients, ownCallSign, timeStamp = VatsimData.getAllVatsimClientsWithOwnCallsignAndTimestamp()

        self.totalVatsimClients = #vatsimClients
        local newRenderClients = self:_convertVatsimClientsToRenderClients(vatsimClients)
        if (#newRenderClients > 0) then
            self.renderClients = newRenderClients
            self.dataTimestamp = timeStamp
        end

        TRACK_ISSUE(
            "Tech Debt / Optimization",
            MULTILINE_TEXT(
                "There are not too many airplanes within the maximum radar range usually (up to 120 at most),",
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
    end

    function RadarPanel:refreshVatsimClients()
        self.newVatsimClientsUpdateAvailable = true
    end

    function RadarPanel:_transformAndClipAllClients(viewHeading)
        local numVisible = 0
        for _, client in ipairs(self.renderClients) do
            client.cameraPos = self:_worldToCameraSpace(client.worldPos)
            client.cameraHeading = client.worldHeading - viewHeading
            client.clipPos = self:_cameraToClipSpace(client.cameraPos)
            if (self:_isVisible(client.clipPos)) then
                numVisible = numVisible + 1
                if (client.isVisible == false) then
                    client.labelVisibility = 0.0
                end
                client.isVisible = true
                client.screenPos = self:_clipToScreenSpace(client.clipPos)
            else
                client.isVisible = false
            end
        end
    end

    function RadarPanel:_renderAllClients()
        imgui.SetWindowFontScale(1.0)
        for _, client in ipairs(self.renderClients) do
            if (client.isVisible) then
                self:_renderClient(client)
            end
        end
    end

    function RadarPanel:_renderAllClientsIconBlockingPass()
        imgui.SetWindowFontScale(1.0)
        for _, client in ipairs(self.renderClients) do
            if (client.isVisible) then
                self:_renderClientIconBlockingPass(client)
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

        self.headingSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        self.zoomSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        self.worldViewPosSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
    end

    Globals.OVERRIDE(RadarPanel.renderToCanvas)
    function RadarPanel:renderToCanvas()
        self:_createBlockingGrid()

        self.zoomSpring:setTarget(self.zoomRange)

        if (self.currentHeadingMode == RadarPanel.Constants.HeadingMode.Heading) then
            if (self.currentFollowMode == RadarPanel.Constants.FollowMode.Follow) then
                self:_setNewHeadingTarget(Datarefs.getCurrentHeading())
            end
        else
            self:_setNewHeadingTarget(0.0)
        end

        local viewHeading = self.headingSpring:getCurrentPosition() % 360.0

        local ownWorldPos =
            self:_convertVatsimLocationToFlat3DKm(Datarefs.getCurrentLatitude(), Datarefs.getCurrentLongitude(), 0.0)

        if (self.currentFollowMode == RadarPanel.Constants.FollowMode.Follow) then
            self.worldViewPosSpring:setTarget(ownWorldPos)
        end

        local worldViewPos = self.worldViewPosSpring:getCurrentPosition()

        self:_precomputeFrameConstants(viewHeading, {worldViewPos[1], worldViewPos[2]})

        local ownScreenPos = self:_worldToCameraSpace(ownWorldPos)
        ownScreenPos = self:_cameraToClipSpace(ownScreenPos)
        ownScreenPos = self:_clipToScreenSpace(ownScreenPos)

        self:_transformAndClipAllClients(viewHeading)

        imgui.PushClipRect(0, 0, self.realScreenWidth, self.realScreenHeight, true)

        self:_renderDistanceCircles(ownWorldPos, ownScreenPos, worldViewPos, viewHeading)
        self:_renderCompass()
        self:_renderHeadingLine(ownScreenPos, ownWorldPos, Datarefs.getCurrentHeading())

        self:_renderAllClientsIconBlockingPass()
        self:_renderAllClients()
        self:_renderOwnMarker(ownScreenPos, Datarefs.getCurrentHeading(), viewHeading)

        -- self.DEBUG_BLOCKING_GRID(
        --     function()
        --         self:_renderBlockingGrid()
        --     end
        -- )

        imgui.PopClipRect()

        self:_renderControlButtons(ownWorldPos, viewHeading)
        self:_renderTimestamp()

        imgui.SetCursorPos(0.0, 309.0)
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
            if (diff > 60.0) then
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
        local headingRotation = Matrix2x2:newRotationMatrix(-ownWorldHeading * Utilities.DegToRad)
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

    function RadarPanel:_renderControlButtons(ownWorldPos, viewHeading)
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

        local diffVec = vector2Substract(self.worldViewPosSpring:getCurrentTargetPosition(), ownWorldPos)
        local d = vector2Length(diffVec)

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

        if (vector2Length(panVector) > 0.0) then
            self.currentFollowMode = RadarPanel.Constants.FollowMode.Free

            local panRotation = Matrix2x2:newRotationMatrix((360.0 - viewHeading) * Utilities.DegToRad)
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

    function RadarPanel:_createBlockingGrid()
        self.blockingGridLen = 20
        if (self.blockingGrid == nil) then
            self.blockingGrid = {}
        end

        for y = 1, self.blockingGridLen do
            for x = 1, self.blockingGridLen do
                self.blockingGrid[y * self.blockingGridLen + x] = 0
            end
        end
    end

    function RadarPanel:_fillBlockingGrid(gridPos)
        local i = gridPos[2] * self.blockingGridLen + gridPos[1]
        local v = self.blockingGrid[i]
        self.blockingGrid[i] = v + 1
    end

    function RadarPanel:_emptyBlockingGrid(gridPos)
        local i = gridPos[2] * self.blockingGridLen + gridPos[1]
        local v = self.blockingGrid[i]
        self.blockingGrid[i] = v - 1
    end

    function RadarPanel:_getBlockValueFromGrid(gridPos)
        return self.blockingGrid[gridPos[2] * self.blockingGridLen + gridPos[1]]
    end

    function RadarPanel:_mapToBlockingGrid(screenPos)
        return {
            math.max(
                1,
                math.min(
                    self.blockingGridLen,
                    (math.floor((self.blockingGridLen * screenPos[1]) / self.screenWidth) + 1)
                )
            ),
            math.max(
                1,
                math.min(
                    self.blockingGridLen,
                    (math.floor((self.blockingGridLen * screenPos[2]) / self.screenHeight) + 1)
                )
            )
        }
    end

    function RadarPanel:_emptyIconInBlockingGrid(screenPos)
        self:_emptyBlockingGridAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.HalfIconSize,
                screenPos[2] - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_emptyBlockingGridAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize,
                screenPos[2] - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_emptyBlockingGridAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize,
                screenPos[2] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_emptyBlockingGridAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.HalfIconSize,
                screenPos[2] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize
            }
        )
    end

    function RadarPanel:_fillBlockingGridAtScreenPos(screenPos)
        self:_fillBlockingGrid(self:_mapToBlockingGrid(screenPos))
        -- self.DEBUG_BLOCKING_GRID(
        --     function()
        --         self:_renderDebugPixels(screenPos, 1, 1, 0xFF00FFFF)
        --     end
        -- )
    end

    function RadarPanel:_emptyBlockingGridAtScreenPos(screenPos)
        self:_emptyBlockingGrid(self:_mapToBlockingGrid(screenPos))
    end

    function RadarPanel:_renderIconToBlockingGrid(screenPos)
        self:_fillBlockingGridAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.HalfIconSize,
                screenPos[2] - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_fillBlockingGridAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize,
                screenPos[2] - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_fillBlockingGridAtScreenPos(
            {
                screenPos[1] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize,
                screenPos[2] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize
            }
        )
        self:_fillBlockingGridAtScreenPos(
            {
                screenPos[1] - RadarPanel.Constants.HalfIconSize,
                screenPos[2] + RadarPanel.Constants.IconSize - RadarPanel.Constants.HalfIconSize
            }
        )
    end

    function RadarPanel:_renderTextToBlockingGrid(screenPos, textLen)
        local actualScreenPos = {screenPos[1] - 9, screenPos[2] - 3}
        local blockage = 0
        local startPos = self:_mapToBlockingGrid(actualScreenPos)
        local startX = startPos[1]
        local startY = startPos[2]
        local maxX = startX
        local maxY = startY
        for t = 1, textLen do
            local currentCharacterPos = nil
            local gridPos = nil

            currentCharacterPos = {actualScreenPos[1] + t * 7, actualScreenPos[2]}
            gridPos = self:_mapToBlockingGrid(currentCharacterPos)
            maxX = math.max(maxX, gridPos[1])
            blockage = blockage + self:_getBlockValueFromGrid(gridPos)

            -- self.DEBUG_BLOCKING_GRID(
            --     function()
            --         self:_renderDebugPixels(currentCharacterPos, 1, 1, 0xFF00FFFF)
            --     end
            -- )

            currentCharacterPos = {actualScreenPos[1] + t * 7, actualScreenPos[2] + 9}
            gridPos = self:_mapToBlockingGrid(currentCharacterPos)
            maxY = math.max(maxY, gridPos[2])
            blockage = blockage + self:_getBlockValueFromGrid(gridPos)

            -- self.DEBUG_BLOCKING_GRID(
            --     function()
            --         self:_renderDebugPixels(currentCharacterPos, 1, 1, 0xFF00FFFF)
            --     end
            -- )
        end

        if (blockage == 0) then
            for y = startY, maxY do
                for x = startX, maxX do
                    self:_fillBlockingGrid({x, y})
                end
            end
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
        for n = 0, 359 do
            if (n % 30 == 0) then
                local compassRotation = Matrix2x2:newRotationMatrix(-n * Utilities.DegToRad)
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
                imgui.SetCursorPos(
                    math.floor(compassPoint[1]) - (compassStr:len() * 2.7),
                    math.floor(compassPoint[2] - 8)
                )
                local compassColor = Globals.Colors.darkerBlue
                if (n % 90 == 0) then
                    compassColor = Globals.Colors.a320Blue
                end
                if (n == 0) then
                    imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.darkerOrange)
                    imgui.TextUnformatted("N")
                else
                    imgui.PushStyleColor(imgui.constant.Col.Text, compassColor)
                    imgui.TextUnformatted(("%s"):format(compassStr))
                end
                imgui.PopStyleColor()
            end
        end
    end

    function RadarPanel:_renderClientIconBlockingPass(client)
        self:_renderIconToBlockingGrid(client.screenPos)
    end

    function RadarPanel:_renderBlockingGrid()
        for y = 1, self.blockingGridLen do
            for x = 1, self.blockingGridLen do
                local v = self.blockingGrid[y * self.blockingGridLen + x]
                self:_renderDebugPixels(
                    {
                        ((x - 1) * self.screenWidth) / self.blockingGridLen,
                        ((y - 1) * self.screenHeight) / self.blockingGridLen
                    },
                    self.screenWidth / self.blockingGridLen,
                    self.screenHeight / self.blockingGridLen,
                    Utilities.lerpColors(0x2200FF00, 0x220000FF, Utilities.Math.lerp(0.0, 1.0, math.min(1.0, v)))
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

    function RadarPanel:_renderClient(client)
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
            end
            if (isOwnClient) then
                isOwnObserverClient = true
            end
            icon = self.stationIcon
        end

        if (not isOwnObserverClient) then
            self:_emptyIconInBlockingGrid(client.screenPos)
        end

        if (isOwnClient) then
            color = Globals.Colors.darkerOrange
        else
            local textScreenPos = {math.floor(client.screenPos[1] - client.name:len() * 2.7), client.screenPos[2] + 10}
            local textLen = client.name:len()
            local blockage = self:_renderTextToBlockingGrid(textScreenPos, textLen)
            if (blockage == 0) then
                client.labelVisibility = math.min(1.0, client.labelVisibility + 1.0 * self.frameTime.cappedDt)
            else
                client.labelVisibility = math.max(0.0, client.labelVisibility - 1.0 * self.frameTime.cappedDt)
            end

            if (client.labelVisibility > 0.25) then
                imgui.SetCursorPos(math.floor(client.screenPos[1] - textLen * 2.7), client.screenPos[2] + 10)
                local actualColor =
                    Utilities.lerpColors(0x00000000, color, math.min(1.0, (client.labelVisibility - 0.25) * 2.0))
                imgui.PushStyleColor(imgui.constant.Col.Text, actualColor)
                imgui.TextUnformatted(client.name)
                imgui.PopStyleColor()
            end
        end

        if (not isOwnObserverClient) then
            self:_renderImageQuad(
                icon,
                RadarPanel.Constants.HalfIconSize,
                client.screenPos,
                client.cameraHeading,
                color
            )

            self:_renderIconToBlockingGrid(client.screenPos)
        end
    end

    function RadarPanel:_renderImageQuad(imageId, imageHalfSize, screenPos, rotation, color)
        local leftTopPos = {-imageHalfSize, -imageHalfSize}
        local rightTopPos = {imageHalfSize, -imageHalfSize}
        local rightBottomPos = {imageHalfSize, imageHalfSize}
        local leftBottomPos = {-imageHalfSize, imageHalfSize}

        local rotationAngle = (rotation * Utilities.DegToRad) % Utilities.FullCircleRadians
        local rotationMatrix = Matrix2x2:newRotationMatrix(rotationAngle)

        leftTopPos = rotationMatrix:multiplyVector2(leftTopPos)
        rightTopPos = rotationMatrix:multiplyVector2(rightTopPos)
        rightBottomPos = rotationMatrix:multiplyVector2(rightBottomPos)
        leftBottomPos = rotationMatrix:multiplyVector2(leftBottomPos)

        local paddingVec =
            vector2Add(screenPos, {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding})
        leftTopPos = vector2Add(leftTopPos, paddingVec)
        rightTopPos = vector2Add(rightTopPos, paddingVec)
        rightBottomPos = vector2Add(rightBottomPos, paddingVec)
        leftBottomPos = vector2Add(leftBottomPos, paddingVec)

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
end

return RadarPanel
