TestInterchangeLinkedDataref = {
    Constants = {
        InitialDatarefValue = 133525,
        InterchangeDatarefId = "Test/InterchangeTest",
        InternalDatarefId = "internal_dataref"
    }
}

InterchangeTestVariable = nil
LinkedReadVariable = nil

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
        nil,
        nil,
        nil
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

function TestInterchangeLinkedDataref:testLoopUpdateDetectsAndAppliesChanges()
    local calledInterchange = false
    local calledLinked = false

    self.object =
        InterchangeLinkedDataref:new(
        InterchangeLinkedDataref.Constants.DatarefTypeInteger,
        self.Constants.InterchangeDatarefId,
        "InterchangeTestVariable",
        self.Constants.InternalDatarefId,
        "LinkedReadVariable",
        function(ild, newInterchangeValue)
            luaUnit.assertEquals(ild, self.object)
            calledInterchange = true
        end,
        function(ild, newLinkedValue)
            luaUnit.assertEquals(ild, self.object)
            calledLinked = true
        end,
        function(ild, newValue)
            return true
        end
    )

    self.object:initialize()
    luaUnit.assertIsFalse(calledInterchange)
    luaUnit.assertIsFalse(calledLinked)

    self.object:loopUpdate()
    luaUnit.assertIsFalse(calledInterchange)
    luaUnit.assertIsFalse(calledLinked)

    local interchangeDataref = flyWithLuaStub.datarefs[self.Constants.InterchangeDatarefId]
    local newValue = self.Constants.InitialDatarefValue + 1337
    interchangeDataref.data = newValue
    flyWithLuaStub:writeAllDatarefValuesToLocalVariables()

    self.object:loopUpdate()
    flyWithLuaStub:writeAllDatarefValuesToLocalVariables()
    luaUnit.assertIsTrue(calledInterchange)
    calledInterchange = false
    luaUnit.assertIsFalse(calledLinked)

    luaUnit.assertEquals(InterchangeTestVariable, newValue)
    luaUnit.assertEquals(LinkedReadVariable, newValue)

    self.object:loopUpdate()
    luaUnit.assertIsFalse(calledInterchange)
    luaUnit.assertIsTrue(calledLinked)
end
