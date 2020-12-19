TRACK_ISSUE("Tech Debt / Framework", "Shared Components cannot include themselves via relative path.")
Vector3 = require("vr-radio-helper.shared_components.vector3")

local FlexibleLength3DSpring
do
    FlexibleLength3DSpring = {
        Constants = {
            Epsilon = 0.0001,
            RestEpsilon = 0.0001
        }
    }

    function FlexibleLength3DSpring:_reset()
        self.currentVelocity = Vector3:newZero()
        self.currentTargetPosition = Vector3:newZero()
        self.currentPosition = Vector3:newZero()
        self.lastDistance = 0.0
        self.currentAcceleration = 0.0
        self.isResting = false
    end

    function FlexibleLength3DSpring:new(springConstant, dampeningFactor)
        local newInstanceWithState = {}
        newInstanceWithState.springConstant = springConstant
        newInstanceWithState.dampeningFactor = dampeningFactor

        newInstanceWithState.isResting = false
        newInstanceWithState.actualMoveFunction = self._moveDampenedSpring

        setmetatable(newInstanceWithState, self)
        self.__index = self

        newInstanceWithState:_precomputeRuntimeConstants()
        newInstanceWithState:_reset()
        return newInstanceWithState
    end

    function FlexibleLength3DSpring:_precomputeRuntimeConstants()
        self.springDirection = self.springConstant * -1.0
        self.dampeningDirection = self.springDirection * self.dampeningFactor
    end

    function FlexibleLength3DSpring:setTarget(newTarget)
        if (newTarget ~= self.currentTargetPosition) then
            self.isResting = false
        end
        self.currentTargetPosition = newTarget
    end

    function FlexibleLength3DSpring:getCurrentPosition()
        return self.currentPosition
    end

    function FlexibleLength3DSpring:getCurrentTargetPosition()
        return self.currentTargetPosition
    end

    function FlexibleLength3DSpring:overrideCurrentPosition(newPosition)
        if (newPosition ~= self.currentPosition) then
            self.isResting = false
        end
        self.currentPosition = newPosition
    end

    function FlexibleLength3DSpring:moveSpring(dt, oneOverDt)
        if (self.isResting) then
            return
        end

        self.actualMoveFunction(self, dt, oneOverDt)
        self:_restOrDont()
    end

    function FlexibleLength3DSpring:_restOrDont()
        local netEntropyShortage =
            math.abs(self.lastDistance) + Vector3.squaredLength(self.currentVelocity) +
            Vector3.squaredLength(self.currentAcceleration)
        if (netEntropyShortage < self.Constants.RestEpsilon) then
            self.lastDistance = 0.0
            self.currentPosition = self.currentTargetPosition
            self.currentVelocity = Vector3:newZero()
            self.currentAcceleration = Vector3:newZero()

            self.isResting = true
        end
    end

    function FlexibleLength3DSpring:_moveDampenedSpring(dt, oneOverDt)
        local direction = Vector3.substract(self.currentPosition, self.currentTargetPosition)
        local distance = Vector3.squaredLength(direction)
        self.lastDistance = distance

        local force = {0.0, 0.0, 0.0}

        if (distance > FlexibleLength3DSpring.Constants.Epsilon) then
            local oneOverDistance = 1.0 / distance
            local normalizedDirection = Vector3.scaleScalar(direction, oneOverDistance)
            local springScale = distance * self.springDirection
            local springForce = Vector3.scaleScalar(normalizedDirection, springScale)

            local dampForce = Vector3.scaleScalar(self.currentVelocity, self.dampeningDirection)

            force = Vector3.add(springForce, dampForce)
        end

        self.currentAcceleration = force
        self.currentVelocity = Vector3.add(self.currentVelocity, Vector3.scaleScalar(self.currentAcceleration, dt))
        self.currentPosition = Vector3.add(self.currentPosition, Vector3.scaleScalar(self.currentVelocity, dt))
    end
end

return FlexibleLength3DSpring
