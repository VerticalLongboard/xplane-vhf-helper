local LuaPlatform = require("lua_platform")

local InitializationItem
do
    InitializationItem = {}
    function InitializationItem:new(newTimeout, newName)
        local newInstanceWithState = {
            name = newName,
            timeout = newTimeout,
            initialized = false,
            timedOut = false,
            firstTryTimestamp = nil
        }

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function InitializationItem:_canInitializeNow()
        assert(nil)
    end

    function InitializationItem:_initializeNow()
        assert(nil)
    end

    function InitializationItem:tryInitialize()
        if (self.timedOut or self.initialized) then
            return false
        end

        if (self.firstTryTimestamp == nil) then
            self.firstTryTimestamp = LuaPlatform.Time.now()
            logMsg(("InitializationItem name=%s: Trying the first time."):format(self.name))
        elseif (LuaPlatform.Time.now() - self.firstTryTimestamp > self.timeout) then
            self.timedOut = true
            logMsg(("InitializationItem name=%s: Timed out after time=%f."):format(self.name, self.timeout))
            return false
        end

        if (self:_canInitializeNow()) then
            self:_initializeNow()
            self.initialized = true
            logMsg(
                ("InitializationItem name=%s: Initialized after time=%f."):format(
                    self.name,
                    LuaPlatform.Time.now() - self.firstTryTimestamp
                )
            )
            return true
        end

        return false
    end

    function InitializationItem:hasBeenInitialized()
        return self.initialized
    end

    function InitializationItem:hasTimedOut()
        return self.timedOut
    end
end

return InitializationItem
