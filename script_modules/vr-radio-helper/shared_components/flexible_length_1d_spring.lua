local FlexibleLength1DSpring
do
    FlexibleLength1DSpring = {
        Constants = {
            Epsilon = 0.0001
        }
    }

    function FlexibleLength1DSpring:_reset()
        self.currentSpeed = 0.0
        self.lastTargetPosition = 0.0
        self.currentTargetPosition = 0.0
        self.currentTargetSpeed = 0.0
        self.currentPosition = 0.0
        self.lastDistance = 0.0
        self.currentAcceleration = 0.0
        self.isResting = false
    end

    function FlexibleLength1DSpring:new(springConstant, dampeningFactor)
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

    function FlexibleLength1DSpring:_precomputeRuntimeConstants()
        self.springDirection = self.springConstant * -1.0
        self.dampeningDirection = self.springDirection * self.dampeningFactor
    end

    function FlexibleLength1DSpring:setTarget(newTarget)
        if (newTarget ~= self.currentTargetPosition) then
            self.isResting = false
        end
        self.currentTargetPosition = newTarget
    end

    function FlexibleLength1DSpring:getCurrentPosition()
        return self.currentPosition
    end

    function FlexibleLength1DSpring:getCurrentTargetPosition()
        return self.currentTargetPosition
    end

    function FlexibleLength1DSpring:overrideCurrentPosition(newPosition)
        if (newPosition ~= self.currentPosition) then
            self.isResting = false
        end
        self.currentPosition = newPosition
    end

    function FlexibleLength1DSpring:moveSpring(dt, oneOverDt)
        if (self.isResting) then
            return
        end

        self.actualMoveFunction(self, dt, oneOverDt)
        self:_restOrDont()
    end

    function FlexibleLength1DSpring:_restOrDont()
        local netEntropyShortage =
            math.abs(self.lastDistance) + math.abs(self.currentSpeed) + math.abs(self.currentAcceleration)
        if (netEntropyShortage < self.Constants.Epsilon) then
            self.lastDistance = 0.0
            self.currentPosition = self.currentTargetPosition
            self.currentSpeed = 0.0
            self.currentAcceleration = 0.0

            self.isResting = true
        end
    end

    function FlexibleLength1DSpring:_moveDampenedSpring(dt, oneOverDt)
        local distance = self.currentPosition - self.currentTargetPosition
        self.lastDistance = distance

        local springForce = distance * self.springDirection

        local dampForce = self.currentSpeed * self.dampeningDirection

        self.currentAcceleration = springForce + dampForce
        self.currentSpeed = self.currentSpeed + self.currentAcceleration * dt
        self.currentPosition = self.currentPosition + self.currentSpeed * dt
    end
end

return FlexibleLength1DSpring
