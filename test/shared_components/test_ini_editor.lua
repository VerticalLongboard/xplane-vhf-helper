local IniEditor = require("vhf_helper.shared_components.ini_editor")
local Utilities = require("vhf_helper.shared_components.utilities")

TestIniEditor = {
    TestKeyMatcher = "^.-Key$",
    TestFilePath = ".\\test\\shared_components\\test_ini_file.ini",
    ActualLoadPath = SCRIPT_DIRECTORY .. "test_ini_file.ini"
}

function TestIniEditor:setUp()
    Utilities.copyFile(self.TestFilePath, self.ActualLoadPath)

    self.object = IniEditor:new()
    luaUnit.assertIsTrue(self.object:loadFromFile(self.ActualLoadPath))
end

function TestIniEditor:testLoadingFromFileWorks()
    local c = self.object:getReadOnlyStructuredContent()
    luaUnit.assertNotNil(c.FirstSection)
    luaUnit.assertNotNil(c.SecondSection)
    luaUnit.assertNotNil(c.SecondSection.someKey)
    luaUnit.assertEquals(c.SecondSection.someKey, "anotherValue")
    luaUnit.assertNotNil(c.SecondSection["second/Key"])
    luaUnit.assertEquals(c.SecondSection["second/Key"], "a value")
    luaUnit.assertEquals(c.SecondSection.accountSettings, "no")
    luaUnit.assertNotNil(c.AnotherSection)
    luaUnit.assertNotNil(c.AnotherSection.thatsAKey)
    luaUnit.assertEquals(c.AnotherSection.thatsAKey, "yes")

    local l = self.object:getReadOnlyUnstructuredLines()
    luaUnit.assertEquals(#l, 12)
    luaUnit.assertEquals(l[1].text, "")
    luaUnit.assertEquals(l[2].comment, " Comment")
    luaUnit.assertEquals(l[3].comment, "Another comment")
    luaUnit.assertEquals(l[4].sectionName, "FirstSection")
    luaUnit.assertEquals(l[5].sectionName, "SecondSection")
    luaUnit.assertEquals(l[6].key, "someKey")
    luaUnit.assertEquals(l[6].value, "anotherValue")
    luaUnit.assertEquals(l[7].key, "second/Key")
    luaUnit.assertEquals(l[7].value, "a value")
    luaUnit.assertEquals(l[8].key, "accountSettings")
    luaUnit.assertEquals(l[8].value, "no")
    luaUnit.assertEquals(l[9].text, "")
    luaUnit.assertEquals(l[10].comment, " add a section")
    luaUnit.assertEquals(l[11].sectionName, "AnotherSection")
    luaUnit.assertEquals(l[12].key, "thatsAKey")
    luaUnit.assertEquals(l[12].value, "yes")
end

function TestIniEditor:testKeyExistenceCheckingWorks()
    luaUnit.assertIsTrue(self.object:doesKeyValueExist("SecondSection", "accountSettings", "no"))
    luaUnit.assertIsFalse(self.object:doesKeyValueExist("First Section", "haha", "noo!"))
    luaUnit.assertIsFalse(self.object:doesKeyValueExist("Unknown Section", "...", "sip, no!"))
end

function TestIniEditor:testLoadFilePathIsSavedCorrectly()
    luaUnit.assertEquals(self.object:getFilePath(), self.ActualLoadPath)
end

function TestIniEditor:testGettingAllKeyValuesByMatcherWorks()
    local allLines = self.object:getAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher)
    luaUnit.assertEquals(#allLines, 3)
    luaUnit.assertEquals(allLines[1].key, "someKey")
    luaUnit.assertEquals(allLines[2].key, "second/Key")
    luaUnit.assertEquals(allLines[3].key, "thatsAKey")
end

function TestIniEditor:testRemovingAllKeyValuesByMatcherWorks()
    local allLines = nil

    allLines = self.object:getAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher)
    luaUnit.assertEquals(#allLines, 3)
    self.object:removeAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher)
    allLines = self.object:getAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher)
    luaUnit.assertEquals(#allLines, 0)

    luaUnit.assertNil(self.object:getReadOnlyStructuredContent().SecondSection.someKey)
    luaUnit.assertNil(self.object:getReadOnlyStructuredContent().SecondSection["second/Key"])
    luaUnit.assertNil(self.object:getReadOnlyStructuredContent().AnotherSection.thatsAKey)
end

function TestIniEditor:testAddingKeyValueLineWorks()
    local c = self.object:getReadOnlyStructuredContent()
    local l = self.object:getReadOnlyUnstructuredLines()
    local allLines = nil

    local matchingLinesBefore = #(self.object:getAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher))
    luaUnit.assertEquals(c.FirstSection.NewKey, nil)
    self.object:addKeyValueLine("FirstSection", "NewKey", "FreshValue")

    local matchingLinesAfter = #(self.object:getAllKeyValueLinesByKeyMatcher(self.TestKeyMatcher))
    luaUnit.assertEquals(matchingLinesAfter, matchingLinesBefore + 1)
    luaUnit.assertEquals(c.FirstSection.NewKey, "FreshValue")
    luaUnit.assertEquals(l[4].sectionName, "FirstSection")

    luaUnit.assertEquals(l[5].key, "NewKey")
    luaUnit.assertEquals(l[5].value, "FreshValue")

    luaUnit.assertEquals(l[6].sectionName, "SecondSection")

    local totalLinesBefore = #l
    self.object:addKeyValueLine("NewSection", "hm", "yep")

    local totalLinesAfter = #l
    luaUnit.assertEquals(totalLinesAfter, totalLinesBefore + 2)
    luaUnit.assertEquals(c.NewSection.hm, "yep")
    luaUnit.assertEquals(l[14].sectionName, "NewSection")
    luaUnit.assertEquals(l[15].key, "hm")
    luaUnit.assertEquals(l[15].value, "yep")
end

function TestIniEditor:testAddingDuplicateKeyValueLineDoesNotWork()
    luaUnit.assertIsFalse(self.object:addKeyValueLine("AnotherSection", "thatsAKey", "yes"))
end

function TestIniEditor:testSavingToFileWorksAndAddsOnlyAnotherNewlineAtMost()
    local writeFilePath = SCRIPT_DIRECTORY .. "test_ini_editor_output.ini"
    luaUnit.assertNotEquals(writeFilePath, self.ActualLoadPath)
    self.object:saveToFile(writeFilePath)
    luaUnit.assertNotNil(self.object:getFilePath())
    local loadFileContent = Utilities.readAllContentFromFile(self.object:getFilePath())
    local writeFileContent = Utilities.readAllContentFromFile(writeFilePath)

    luaUnit.assertEquals(writeFileContent, loadFileContent .. "\n")
end
