local FlexibleLength1DSpring
do
    FlexibleLength1DSpring = {
        Constants = {
            Epsilon = 0.0001,
            MaxDt = 1 / 30.0
        }
    }

    function FlexibleLength1DSpring:reset()
        self.currentPosition = 0.0
        self.currentSpeed = 0.0
        self.currentTarget = 0.0
    end

    function FlexibleLength1DSpring:new(dampingConstant, springConstant)
        local newInstanceWithState = {}
        newInstanceWithState.dampingConstant = dampingConstant
        newInstanceWithState.springConstant = springConstant
        newInstanceWithState.isResting = false
        setmetatable(newInstanceWithState, self)
        self.__index = self
        self:reset()
        return newInstanceWithState
    end

    function FlexibleLength1DSpring:getCurrentPosition()
        return self.currentPosition
    end

    function FlexibleLength1DSpring:overrideCurrentPosition(newPosition)
        self.currentPosition = newPosition
        self.isResting = false
    end

    function FlexibleLength1DSpring:moveSpring(dt)
        if (self.isResting) then
            return
        end

        dt = math.min(self.Constants.MaxDt, dt)
        local distance = self.currentPosition - self.currentTarget
        local force = 0.0
        if (math.abs(distance) > self.Constants.Epsilon) then
            local springForce = distance * self.springConstant * -1.0
            local dampForce = self.currentSpeed * self.dampingConstant
            force = springForce - dampForce
        end

        self.currentSpeed = self.currentSpeed + force * dt
        self.currentPosition = self.currentPosition + self.currentSpeed * dt

        if
            (self.currentPosition - self.currentTarget < self.Constants.Epsilon and
                self.currentSpeed < self.Constants.Epsilon)
         then
            self.currentSpeed = 0.0
            self.currentPosition = self.currentTarget
            self.isResting = true
        end
    end

    function FlexibleLength1DSpring:setTarget(newTarget)
        self.currentTarget = newTarget
        self.isResting = false
    end
end

return FlexibleLength1DSpring
