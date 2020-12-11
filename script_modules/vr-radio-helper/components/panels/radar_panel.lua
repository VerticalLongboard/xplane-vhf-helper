local Globals = require("vr-radio-helper.globals")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local SubPanel = require("vr-radio-helper.components.panels.sub_panel")
local FlexibleLength1DSpring = require("vr-radio-helper.shared_components.flexible_length_1d_spring")
local VatsimData = require("vr-radio-helper.state.vatsim_data")
local Datarefs = require("vr-radio-helper.state.datarefs")

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
        ImguiTopLeftPadding = 5,
        MaxZoomRange = 600.0
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

        self.currentHeadingMode = RadarPanel.Constants.HeadingMode.Heading
        self.headingSpring = FlexibleLength1DSpring:new(100, 0.2)
        self.zoomSpring = FlexibleLength1DSpring:new(100, 0.2)
        self.zoomRange = RadarPanel.Constants.MaxZoomRange
        self.zoomSpring:setTarget(self.zoomRange)
        self.vatsimClients = nil

        self.renderClients = {}

        self.totalVatsimClients = 0

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
                    "break at client=" ..
                        (vatsimClient.callSign or vatsimClient.id) ..
                            " num=" .. tostring(num) .. "/" .. tostring(#vatsimclientTable)
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
                        frequency = vatsimClient.frequency
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

    function vector2Substract(v, minusV)
        return {v[1] - minusV[1], v[2] - minusV[2]}
    end

    function vector2Add(v, plusV)
        return {v[1] + plusV[1], v[2] + plusV[2]}
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

    Globals.OVERRIDE(RadarPanel.loop)
    function RadarPanel:loop(frameTime)
        SubPanel.loop(self, frameTime)
        self.headingSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
        self.zoomSpring:moveSpring(frameTime.cappedDt, frameTime.oneOverCappedDt)
    end

    function RadarPanel:_precomputeFrameConstants(viewRotation, worldViewPosition)
        self.realScreenWidth = 254
        self.realScreenHeight = 308
        self.screenWidth = 254 - RadarPanel.Constants.ImguiTopLeftPadding
        self.screenHeight = 308 - RadarPanel.Constants.ImguiTopLeftPadding
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

    function RadarPanel:refreshVatsimClients()
        local vatsimClients, ownCallSign, timeStamp = VatsimData.getAllVatsimClientsWithOwnCallsignAndTimestamp()
        self.totalVatsimClients = #vatsimClients
        local newRenderClients = self:_convertVatsimClientsToRenderClients(vatsimClients)
        if (#newRenderClients > 0) then
            self.renderClients = newRenderClients
        end

        self.ownClient = nil
        for _, client in ipairs(self.renderClients) do
            if (client.name == ownCallSign) then
                self.ownClient = client
                break
            end
        end
    end

    Globals.OVERRIDE(RadarPanel.renderToCanvas)
    function RadarPanel:renderToCanvas()
        -- TODO: Add own render client
        -- TODO: Add timestamp
        -- TODO: Add pos
        -- TODO: Add heading line
        self.zoomSpring:setTarget(self.zoomRange)

        if (self.currentHeadingMode == RadarPanel.Constants.HeadingMode.Heading) then
            self:_setNewHeadingTarget(Datarefs.getCurrentHeading())
        else
            self:_setNewHeadingTarget(0.0)
        end

        local heading = self.headingSpring:getCurrentPosition() % 360.0

        local ownWorldPos =
            self:_convertVatsimLocationToFlat3DKm(Datarefs.getCurrentLatitude(), Datarefs.getCurrentLongitude(), 0.0)

        self:_precomputeFrameConstants(heading, {ownWorldPos[1], ownWorldPos[2]})

        local ownScreenPos = self:_worldToCameraSpace(ownWorldPos)
        ownScreenPos = self:_cameraToClipSpace(ownScreenPos)
        ownScreenPos = self:_clipToScreenSpace(ownScreenPos)

        local numVisible = 0

        for _, client in ipairs(self.renderClients) do
            client.cameraPos = self:_worldToCameraSpace(client.worldPos)
            client.cameraHeading = client.worldHeading - heading
            client.clipPos = self:_cameraToClipSpace(client.cameraPos)
            if (self:_isVisible(client.clipPos)) then
                numVisible = numVisible + 1
                client.isVisible = true
                client.screenPos = self:_clipToScreenSpace(client.clipPos)
            else
                client.isVisible = false
            end
        end

        imgui.PushClipRect(0, 0, self.realScreenWidth, self.realScreenHeight, true)

        self:_renderDistanceCircles(ownScreenPos, heading)
        self:_renderCompass()

        imgui.SetWindowFontScale(1.0)
        for _, client in ipairs(self.renderClients) do
            if (client ~= self.ownClient and client.isVisible) then
                self:_drawClient(client, self.ownClient)
            end
        end

        if (self.ownClient ~= nil) then
            self:_drawClient(self.ownClient, self.ownClient)
        end

        imgui.PopClipRect()

        -- imgui.SetCursorPos(5, 20)
        -- imgui.TextUnformatted("")
        -- imgui.TextUnformatted(("%d/%d/%d"):format(numVisible, #self.renderClients, self.totalVatsimClients))

        self:_renderControlButtons()

        imgui.SetCursorPos(0.0, 309.0)
    end

    function RadarPanel:_renderControlButtons()
        imgui.SetCursorPos(5, 5)
        imgui.PushStyleColor(imgui.constant.Col.Button, Globals.Colors.defaultImguiButtonBackground)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Globals.Colors.defaultImguiButtonBackground)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, Globals.Colors.slightlyBrighterDefaultButtonColor)

        if (imgui.Button("-")) then
            if (self.zoomRange < RadarPanel.Constants.MaxZoomRange) then
                self.zoomRange = self.zoomRange * 2.0
            end
        end

        imgui.SameLine()
        if (imgui.Button("+")) then
            if (self.zoomRange > 0.29296875) then
                self.zoomRange = self.zoomRange * 0.5
            end
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
            end
        end

        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end

    function RadarPanel:_renderDistanceCircles(ownScreenPos, heading)
        local currentCircleNm = 0.15625
        local circleRotation = Matrix2x2:newRotationMatrix((-45.0 - heading) * Utilities.DegToRad)
        for c = 1, 12 do
            local circleKm = currentCircleNm * Utilities.NmToKm

            local circlePoint = {0.0, circleKm * 1.0}
            circlePoint = circleRotation:multiplyVector2(circlePoint)
            circlePoint = vector2Add(self.worldViewPosition, circlePoint)

            circlePoint = self:_worldToCameraSpace(circlePoint)
            circlePoint = self:_cameraToClipSpace(circlePoint)
            circlePoint = self:_clipToScreenSpace(circlePoint)

            circlePoint =
                vector2Add(
                circlePoint,
                {RadarPanel.Constants.ImguiTopLeftPadding, RadarPanel.Constants.ImguiTopLeftPadding}
            )

            local circleStr = nil
            if (currentCircleNm <= 2.5) then
                circleStr = ("%.2f"):format(currentCircleNm)
            else
                circleStr = ("%.0f"):format(currentCircleNm)
            end
            imgui.SetCursorPos(math.floor(circlePoint[1] - (circleStr:len() * 2.7)) - 5, math.floor(circlePoint[2] - 8))

            local circleAlpha =
                math.min(255.0, Utilities.Math.lerp(0, 255.0, circleKm / self.zoomSpring:getCurrentPosition()))
            local circleTextColor = 0x00CCCCCC
            local circleColor = 0x00222222
            circleTextColor = Utilities.Color.setAlpha(circleTextColor, circleAlpha)
            circleColor = Utilities.Color.setAlpha(circleColor, circleAlpha)

            imgui.DrawList_AddCircle(
                ownScreenPos[1] + RadarPanel.Constants.ImguiTopLeftPadding,
                ownScreenPos[2] + RadarPanel.Constants.ImguiTopLeftPadding,
                circleKm * self.oneOverZoomRatio,
                circleColor,
                36,
                3.0
            )

            imgui.PushStyleColor(imgui.constant.Col.Text, circleTextColor)
            imgui.TextUnformatted(circleStr)
            imgui.PopStyleColor()

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

    function RadarPanel:_drawClient(client, ownClient)
        local halfIconSize = 5

        local icon = nil
        local color = Globals.Colors.white
        if (client.type == RadarPanel.Constants.ClientType.Plane) then
            if (client == ownClient) then
                color = Globals.Colors.a320Orange
            end
            icon = self.planeIcon
        else
            if (VHFHelperPublicInterface.isCurrentlyTunedIn(client.frequency)) then
                color = Globals.Colors.a320Orange
            end
            icon = self.stationIcon
        end

        if (client ~= ownClient) then
            imgui.SetCursorPos(math.floor(client.screenPos[1] - client.name:len() * 2.7), client.screenPos[2] + 10)
            imgui.PushStyleColor(imgui.constant.Col.Text, color)
            imgui.TextUnformatted(client.name)
            imgui.PopStyleColor()
        end

        self:_drawImageQuad(icon, halfIconSize, client.screenPos, client.cameraHeading, color)
    end

    function RadarPanel:_drawImageQuad(imageId, imageHalfSize, screenPos, rotation, color)
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
