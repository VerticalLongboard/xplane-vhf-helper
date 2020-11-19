TestInterchangeLinkedDataref = {
    Constants = {
        InitialDatarefValue = 133525,
        InterchangeDatarefId = "Test/InterchangeTest",
        InternalDatarefId = "internal_dataref"
    },
    calledInterchange = false,
    calledLinked = false,
    calledIsValid = false
}

InterchangeTestVariable = nil
LinkedReadVariable = nil

function TestInterchangeLinkedDataref:_resetCallbackCallState()
    self.calledInterchange = false
    self.calledLinked = false
    self.calledIsValid = false
end

function TestInterchangeLinkedDataref:setUp()
    flyWithLuaStub:createSharedDatarefHandle(
        "internal_dataref",
        flyWithLuaStub.Constants.DatarefTypeInteger,
        self.Constants.InitialDatarefValue
    )

    self.object =
        InterchangeLinkedDataref:new(
        InterchangeLinkedDataref.Constants.DatarefTypeInteger,
        self.Constants.InterchangeDatarefId,
        "InterchangeTestVariable",
        self.Constants.InternalDatarefId,
        "LinkedReadVariable",
        function(ild, newInterchangeValue)
            luaUnit.assertEquals(ild, TestInterchangeLinkedDataref.object)
            TestInterchangeLinkedDataref.calledInterchange = true
        end,
        function(ild, newLinkedValue)
            luaUnit.assertEquals(ild, TestInterchangeLinkedDataref.object)
            TestInterchangeLinkedDataref.calledLinked = true
        end,
        function(ild, newValue)
            TestInterchangeLinkedDataref.calledIsValid = true
            return true
        end
    )

    self.object:initialize()
end

function TestInterchangeLinkedDataref:testInitializationWritesCurrentLinkedValueToInterchange()
    luaUnit.assertEquals(LinkedReadVariable, self.Constants.InitialDatarefValue)
    luaUnit.assertEquals(InterchangeTestVariable, self.Constants.InitialDatarefValue)
end

function TestInterchangeLinkedDataref:testGettingExternallyDefinedVariablesWorks()
    luaUnit.assertEquals(self.object:getLinkedValue(), self.Constants.InitialDatarefValue)
    luaUnit.assertEquals(self.object:getInterchangeValue(), self.Constants.InitialDatarefValue)
end

function TestInterchangeLinkedDataref:testEmittingNewValueUpdatesBothLinkedAndInterchange()
    luaUnit.assertEquals(self.object:getLinkedValue(), self.Constants.InitialDatarefValue)
    luaUnit.assertEquals(self.object:getInterchangeValue(), self.Constants.InitialDatarefValue)

    local newValue = self.Constants.InitialDatarefValue * 2
    self.object:emitNewValue(newValue)
    flyWithLuaStub:readbackAllWritableDatarefs()
    flyWithLuaStub:writeAllDatarefValuesToLocalVariables()

    luaUnit.assertEquals(self.object:getInterchangeValue(), newValue)
    luaUnit.assertEquals(self.object:getLinkedValue(), newValue)
end

function TestInterchangeLinkedDataref:testLoopUpdateDetectsAndAppliesInterchangeChangesImmediatelyAndLinkedChangesAfterOneFrame()
    self.object:initialize()
    luaUnit.assertIsFalse(self.calledInterchange)
    luaUnit.assertIsFalse(self.calledLinked)
    self:_resetCallbackCallState()

    self.object:loopUpdate()
    luaUnit.assertIsFalse(self.calledInterchange)
    luaUnit.assertIsFalse(self.calledLinked)
    self:_resetCallbackCallState()

    local interchangeDataref = flyWithLuaStub.datarefs[self.Constants.InterchangeDatarefId]
    local newValue = self.Constants.InitialDatarefValue + 1337
    interchangeDataref.data = newValue
    flyWithLuaStub:writeAllDatarefValuesToLocalVariables()

    self.object:loopUpdate()
    flyWithLuaStub:writeAllDatarefValuesToLocalVariables()
    luaUnit.assertIsTrue(self.calledInterchange)
    luaUnit.assertIsFalse(self.calledLinked)
    self.calledInterchange = false

    luaUnit.assertEquals(InterchangeTestVariable, newValue)
    luaUnit.assertEquals(LinkedReadVariable, newValue)

    self.object:loopUpdate()
    luaUnit.assertIsFalse(self.calledInterchange)
    luaUnit.assertIsTrue(self.calledLinked)
    self.calledInterchange = false
end
