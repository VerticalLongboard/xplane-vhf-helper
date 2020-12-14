local Vector3
do
    Vector3 = {}

    function Vector3:new(x, y, z)
        local newInstanceWithState = {
            x,
            y,
            z
        }
        return newInstanceWithState
    end

    function Vector3:newZero()
        return Vector3:new(0.0, 0.0, 0.0)
    end

    function Vector3.add(v1, v2)
        return Vector3:new(v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3])
    end

    function Vector3.scale(v1, v2)
        return Vector3:new(v1[1] * v2[1], v1[2] * v2[2], v1[3] * v2[3])
    end

    function Vector3.substract(v1, v2)
        return Vector3:new(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
    end

    function Vector3.length(v1)
        return math.sqrt(v1[1] * v1[1] + v1[2] * v1[2] + v1[3] * v1[3])
    end

    function Vector3.distance(v1, v2)
        local xDiffSquared = v1[1] - v2[1]
        xDiffSquared = xDiffSquared * xDiffSquared
        local yDiffSquared = v1[2] - v2[2]
        yDiffSquared = yDiffSquared * yDiffSquared
        local zDiffSquared = v1[3] - v2[3]
        zDiffSquared = zDiffSquared * zDiffSquared
        return math.sqrt(xDiffSquared + yDiffSquared + zDiffSquared)
    end
end

return Vector3
