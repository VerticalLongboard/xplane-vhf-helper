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
            firstTryTimestamp = nil,
            triesSoFar = 0
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

    TRACK_ISSUE(
        "InitializationItem",
        "When blocking the main thread (because of loading an airplane etc.), important items may time out without even trying.",
        "Give them a chance to initialize at least one last time _before_ they time out, i.e. check timeout after trying."
    )
    function InitializationItem:tryInitialize()
        if (self.timedOut or self.initialized) then
            return false
        end

        if (self:_canInitializeNow()) then
            self:_initializeNow()
            self.initialized = true

            if (self.firstTryTimestamp == nil) then
                logMsg(("InitializationItem name=%s: Initialized on first try."):format(self.name))
            else
                logMsg(
                    ("InitializationItem name=%s: Initialized after time=%f."):format(
                        self.name,
                        LuaPlatform.Time.now() - self.firstTryTimestamp
                    )
                )
            end
            return true
        end

        self.triesSoFar = self.triesSoFar + 1

        if (self.firstTryTimestamp == nil) then
            self.firstTryTimestamp = LuaPlatform.Time.now()
            logMsg(("InitializationItem name=%s: First try failed."):format(self.name))
        elseif (LuaPlatform.Time.now() - self.firstTryTimestamp > self.timeout) then
            self.timedOut = true
            logMsg(
                ("InitializationItem name=%s: Timed out after time=%f tries=%d."):format(
                    self.name,
                    self.timeout,
                    self.triesSoFar
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
