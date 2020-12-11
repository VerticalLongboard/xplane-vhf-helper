local Globals = require("vr-radio-helper.globals")
local Utilities = require("vr-radio-helper.shared_components.utilities")

TestRadar = {}

function TestRadar:testSomething()
    function convertVatsimLocationToFlat3DKm(latitude, longitude, altitude)
        return {
            111.320 * longitude * math.cos(latitude * Utilities.DegToRad),
            110.574 * latitude,
            altitude * Utilities.FeetToM
        }
    end

    local vatsimPlanes = {
        {
            callSign = "THATSME",
            latitude = "6.1708",
            longitude = "-75.4276",
            altitude = "39000.0",
            heading = "270.0",
            groundSpeed = "450"
        },
        {
            callSign = "DLH53N",
            latitude = "8.0",
            longitude = "-76.0",
            altitude = "24000.0",
            heading = "183.0",
            groundSpeed = "409"
        },
        {
            callSign = "DLH62X",
            latitude = "7.0",
            longitude = "-76.0",
            altitude = "13000.0",
            heading = "51.0",
            groundSpeed = "220"
        },
        {
            callSign = "DLH57D",
            latitude = "10.0",
            longitude = "-73.0",
            altitude = "23000.0",
            heading = "355.0",
            groundSpeed = "320"
        }
    }

    function convertVatsimPlanesToPlanes(vatsimPlaneTable)
        local planes = {}
        for _, plane in ipairs(vatsimPlaneTable) do
            table.insert(
                planes,
                {
                    callSign = plane.callSign,
                    worldPos = convertVatsimLocationToFlat3DKm(plane.latitude, plane.longitude, plane.altitude),
                    worldHeading = plane.heading,
                    speed = plane.groundSpeed * Utilities.KnotsToKmh
                }
            )
        end

        return planes
    end

    local planes = convertVatsimPlanesToPlanes(vatsimPlanes)

    local mePlane = planes[1]
    local viewPosition = {mePlane.worldPos[1], mePlane.worldPos[2], mePlane.worldPos[3]}
    local heading = mePlane.worldHeading

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
            return {self[1] * multiplyV[1] + self[2] * multiplyV[2], self[3] * multiplyV[1] + self[4] * multiplyV[2]}
        end
    end

    function vector2Substract(v, minusV)
        return {v[1] - minusV[1], v[2] - minusV[2]}
    end

    function worldToCameraSpace(worldPos, viewPosition, viewRotation)
        local translated = vector2Substract(worldPos, viewPosition)
        local rotationAngle = (viewRotation * Utilities.DegToRad) % Utilities.FullCircleRadians
        local rotationMatrix = Matrix2x2:newRotationMatrix(rotationAngle)
        local rotated = rotationMatrix:multiplyVector2(translated)
        return rotated
    end

    function cameraToClipSpace(cameraPos, left, right, top, bottom)
        local clipToScreenMatrix = Matrix2x2:new(1.0 / (right - left), 0.0, 0.0, 1.0 / (bottom - top))
        return clipToScreenMatrix:multiplyVector2(cameraPos)
    end

    function clipToScreenSpace(clipPos, screenWidth, screenHeight)
        return {(clipPos[1] + 0.5) * screenWidth, (1.0 - (clipPos[2] + 0.5)) * screenHeight}
    end

    local zoomRange = 300.0
    local screenWidth = 300.0
    local screenHeight = 400.0

    local aspect = screenWidth / screenHeight
    local left, right, top, bottom = nil
    if (aspect >= 1.0) then
        left = -zoomRange
        right = zoomRange
        top = -zoomRange * aspect
        bottom = zoomRange * aspect
    else
        top = -zoomRange
        bottom = zoomRange
        left = -zoomRange * aspect
        right = zoomRange * aspect
    end

    for _, plane in ipairs(planes) do
        plane.cameraPos = worldToCameraSpace(plane.worldPos, viewPosition, heading)
        plane.cameraHeading = plane.worldHeading - heading
        plane.clipPos = cameraToClipSpace(plane.cameraPos, left, right, top, bottom)
        plane.screenPos = clipToScreenSpace(plane.clipPos, screenWidth, screenHeight)
    end

    for _, plane in ipairs(planes) do
        logMsg(
            ("%s: worldPos=%f/%f/%f worldHeading=%f cameraPos=%f/%f cameraHeading=%f clipPos=%f/%f screenPos=%f/%f speed=%f"):format(
                plane.callSign,
                plane.worldPos[1],
                plane.worldPos[2],
                plane.worldPos[3],
                plane.worldHeading,
                plane.cameraPos[1],
                plane.cameraPos[2],
                plane.cameraHeading,
                plane.clipPos[1],
                plane.clipPos[2],
                plane.screenPos[1],
                plane.screenPos[2],
                plane.speed
            )
        )
    end
end
