local luaUnit = require("luaunit")

function logMsg(stringToLog)
    print("TEST LOG: " .. stringToLog)
end

flyWithLuaStub = {
    Constants = {
        AccessTypeReadable = "readable",
        AccessTypeWritable = "writable",
        AccessTypeHandleOnly = "handleonly",
        DatarefTypeInteger = "Int"
    },
    datarefs = {}
}

function create_command(commandName, readableCommandName, toggleExpressionName, something1, something2)
end

function add_macro(readableScriptName, activateExpression, deactivateExpression, activateOrDeactivate)
end

function define_shared_DataRef(globalDatarefIdName, datarefType)
    local d = {}
    d.type = datarefType
    flyWithLuaStub.datarefs[globalDatarefIdName] = d
end

function dataref(localDatarefVariable, globalDatarefIdName, accessType)
    luaUnit.assertTableContains(
        {flyWithLuaStub.Constants.AccessTypeReadable, flyWithLuaStub.Constants.AccessTypeWritable},
        accessType
    )

    local d = flyWithLuaStub.datarefs[globalDatarefIdName]
    d.localVariableName = localDatarefVariable
    d.localVariableRead = loadstring("return " .. localDatarefVariable)

    if
        (d.localVariableAccessType == flyWithLuaStub.Constants.AccessTypeHandleOnly and
            accessType == flyWithLuaStub.Constants.AccessTypeReadable)
     then
        logMsg(("Warning: Changing dataref=%s from handle to readable"):format(globalDatarefIdName))
    end

    d.localVariableAccessType = accessType

    if (accessType == flyWithLuaStub.Constants.AccessTypeReadable) then
        flyWithLuaStub:writeDatarefValueToLocalVariable(globalDatarefIdName)
    end
end

function flyWithLuaStub:runNextFrameAfterExternalWritesToDatarefs()
    self:readAllWritableDatarefs()
    self.doOftenFunction()
    self.doEveryFrameFunction()
end

function flyWithLuaStub:readAllWritableDatarefs()
    for n, d in pairs(self.datarefs) do
        if (d.localVariableAccessType == self.Constants.AccessTypeWritable) then
            d.data = d.localVariableRead()
        end
    end
end

function flyWithLuaStub:writeDatarefValueToLocalVariable(globalDatarefIdName)
    local d = self.datarefs[globalDatarefIdName]
    local newLocallyDefinedValue = d.data
    d.localVariableWrite = loadstring(d.localVariableName .. " = " .. d.data)
    d.localVariableWrite()
end

function do_often(doOftenExpression)
    flyWithLuaStub.doOftenFunction = loadstring(doOftenExpression)
end

function do_every_frame(doEveryFrameExpression)
    flyWithLuaStub.doEveryFrameFunction = loadstring(doEveryFrameExpression)
end

function XPLMFindDataRef(datarefName)
    luaUnit.assertNotNil(datarefName)
    local d = flyWithLuaStub.datarefs[datarefName]
    if (d == nil) then
        return nil
    end

    luaUnit.assertNotNil(d.localVariableAccessType)

    return datarefName
end

function XPLMSetDatai(datarefName, newDataAsInteger)
    local d = flyWithLuaStub.datarefs[datarefName]
    luaUnit.assertEquals(d.type, flyWithLuaStub.Constants.DatarefTypeInteger)
    d.data = newDataAsInteger
end

SCRIPT_DIRECTORY = "."

return flyWithLuaStub
