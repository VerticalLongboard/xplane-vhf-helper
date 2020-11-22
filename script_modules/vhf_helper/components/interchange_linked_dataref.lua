local InterchangeLinkedDataref
do
    InterchangeLinkedDataref = {
        Constants = {
            DatarefTypeInteger = "Int",
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
            getInterchangeValueFunction = loadstring("return " .. newInterchangeVariableName),
            getLinkedValueFunction = loadstring("return " .. newLinkedReadVariableName)
        }

        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function InterchangeLinkedDataref:initialize()
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
        "Depending on how FlyWithLua actually flushes writable dataref updates to readable datarefs, a change in linked values" ..
            "\n" .. "may be delayed by one frame or not.",
        "Expect the 1-frame-delay in tests for now and behave as if it's not delayed in production code."
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
            self.onLinkedChangeFunction(self, currentLinkedValue)
            self.lastLinkedValue = currentLinkedValue
        end
    end

    function InterchangeLinkedDataref:emitNewValue(value)
        self:_setInterchangeValue(value)
        self:_setLinkedValue(value)
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
        local setInterchangeValueFunction = loadstring(self.interchangeVariableName .. " = " .. value)
        setInterchangeValueFunction()
        self.lastInterchangeValue = value
    end

    function InterchangeLinkedDataref:_setLinkedValue(value)
        XPLMSetDatai(self.linkedDatarefWriteHandle, value)
    end
end

return InterchangeLinkedDataref
