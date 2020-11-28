local LuaPlatform = require("lua_platform")

local InterchangeLinkedDataref
do
    InterchangeLinkedDataref = {
        Constants = {
            DatarefTypeInteger = "Int",
            DatarefTypeFloat = "Float",
            DatarefAccessTypeWritable = "writable",
            DatarefAccessTypeReadable = "readable"
        }
    }
    function InterchangeLinkedDataref:new(
        newDataType,
        newInterchangeDatarefName,
        newInterchangeVariableName,
        newLinkedDatarefName,
        newLinkedReadVariableName,
        newOnInterchangeChangeFunction,
        newOnLinkedChangeFunction,
        newIsNewValueValidFunction)
        assert(newDataType)
        assert(newInterchangeDatarefName)
        assert(newInterchangeVariableName)
        assert(newLinkedDatarefName)
        assert(newLinkedReadVariableName)
        assert(newOnInterchangeChangeFunction)
        assert(newOnLinkedChangeFunction)
        assert(newIsNewValueValidFunction)
        if
            (newDataType ~= InterchangeLinkedDataref.Constants.DatarefTypeInteger and
                newDataType ~= InterchangeLinkedDataref.Constants.DatarefTypeFloat)
         then
            assert(nil)
        end

        local newValue = nil

        local newInstanceWithState = {
            dataType = newDataType,
            interchangeDatarefName = newInterchangeDatarefName,
            interchangeVariableName = newInterchangeVariableName,
            linkedDatarefName = newLinkedDatarefName,
            linkedReadVariableName = newLinkedReadVariableName,
            onInterchangeChangeFunction = newOnInterchangeChangeFunction,
            onLinkedChangeFunction = newOnLinkedChangeFunction,
            isNewValueValidFunction = newIsNewValueValidFunction,
            lastLinkedValue = nil,
            lastInterchangeValue = nil,
            linkedDatarefWriteHandle = nil,
            getInterchangeValueFunction = LOAD_LUA_STRING("return " .. newInterchangeVariableName),
            getLinkedValueFunction = LOAD_LUA_STRING("return " .. newLinkedReadVariableName)
        }

        newInstanceWithState.lastLinkedChangeTimestamp = 0

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function InterchangeLinkedDataref:getInterchangeDatarefName()
        return self.interchangeDatarefName
    end

    function InterchangeLinkedDataref:initialize()
        TRACK_ISSUE(
            "Tech Debt",
            "Make that a notification and show an internal error. Multicrew will not work like that."
        )
        TRACK_ISSUE(
            "FlyWithLua",
            MULTILINE_TEXT(
                "FlyWithLua does not support deleting a dataref.",
                "When running X-Plane while updating dataref types, creating them again will fail, fatally.",
                "Problem: We don't want datarefs to exist already, but bailing out because of it is not viable in production.",
                "Also, there's no way to get the current type so we don't know if the define_shared_DataRef call will fail.",
                "Leaving a log message is considered a good warning, but all FlyWithLua scripts",
                "will fail anyway. Would't expect any user to read Log.txt. A restart fixes it. No real workaround at the moment :-("
            )
        )
        if (XPLMFindDataRef(self.interchangeDatarefName) ~= nil) then
            logMsg(
                ("Dataref Initialization: Dataref name=%s already exists (maybe with a different type). If you see a FlyWithLua Error shortly after this, you need to restart X-Plane."):format(
                    self.interchangeDatarefName
                )
            )
        end

        define_shared_DataRef(self.interchangeDatarefName, self.dataType)
        dataref(self.interchangeVariableName, self.interchangeDatarefName, self.Constants.DatarefAccessTypeWritable)

        dataref(self.linkedReadVariableName, self.linkedDatarefName, self.Constants.DatarefAccessTypeReadable)
        self.linkedDatarefWriteHandle = XPLMFindDataRef(self.linkedDatarefName)

        local linkedValue = self.getLinkedValueFunction()
        self.lastLinkedValue = linkedValue
        self.lastInterchangeValue = linkedValue
        self:_setInterchangeValue(linkedValue)
    end

    TRACK_ISSUE(
        "InterchangeLinkedDataref",
        MULTILINE_TEXT(
            "Depending on how FlyWithLua actually flushes writable dataref updates to",
            "readable datarefs, a change in linked values may be delayed by one frame or not."
        ),
        "Expect the 1-frame-delay in tests for now and behave as if it's not delayed (but it can be) in production code."
    )
    function InterchangeLinkedDataref:loopUpdate()
        local currentInterchangeValue = self:getInterchangeValue()
        if (currentInterchangeValue ~= self.lastInterchangeValue) then
            if (not self.isNewValueValidFunction(self, currentInterchangeValue)) then
                currentInterchangeValue = self:getLinkedValue()
                self:_setInterchangeValue(currentInterchangeValue)
            end

            self.onInterchangeChangeFunction(self, currentInterchangeValue)
            self:_setLinkedValue(currentInterchangeValue)
            self.lastInterchangeValue = currentInterchangeValue
        end

        local currentLinkedValue = self:getLinkedValue()
        if (currentLinkedValue ~= self.lastLinkedValue) then
            self.lastLinkedChangeTimestamp = LuaPlatform.Time.now()
            self.onLinkedChangeFunction(self, currentLinkedValue)
            self.lastLinkedValue = currentLinkedValue
        end
    end

    function InterchangeLinkedDataref:emitNewValue(value)
        self:_setInterchangeValue(value)
        self:_setLinkedValue(value)
    end

    function InterchangeLinkedDataref:getLastLinkedChangeTimestamp()
        return self.lastLinkedChangeTimestamp
    end

    function InterchangeLinkedDataref:getLinkedValue()
        return self.getLinkedValueFunction()
    end

    function InterchangeLinkedDataref:getInterchangeValue()
        return self.getInterchangeValueFunction()
    end

    function InterchangeLinkedDataref:isLocalLinkedDatarefAvailable()
        return XPLMFindDataRef(self.linkedDatarefName)
    end

    function InterchangeLinkedDataref:_setInterchangeValue(value)
        local setInterchangeValueFunction = LOAD_LUA_STRING(self.interchangeVariableName .. " = " .. tostring(value))
        setInterchangeValueFunction()
        self.lastInterchangeValue = value
    end

    function InterchangeLinkedDataref:_setLinkedValue(value)
        if (self.dataType == InterchangeLinkedDataref.Constants.DatarefTypeInteger) then
            XPLMSetDatai(self.linkedDatarefWriteHandle, value)
        elseif (self.dataType == InterchangeLinkedDataref.Constants.DatarefTypeFloat) then
            XPLMSetDataf(self.linkedDatarefWriteHandle, value)
        else
            assert(nil)
        end
    end
end

return InterchangeLinkedDataref
