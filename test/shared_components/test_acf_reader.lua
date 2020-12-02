local AcfReader = require("vr-radio-helper.shared_components.acf_reader")

TestAcfReader = {
    TestFilePath = ".\\test\\shared_components\\test_acf_file.acf"
}

function TestAcfReader:setUp()
    self.object = AcfReader:new()
    luaUnit.assertIsTrue(self.object:loadFromFile(self.TestFilePath))
end

function TestAcfReader:testReadingAFileWorks()
    luaUnit.assertEquals(self.object:getPropertyValue("_cgpt/5/_w_max"), "0.0")
    luaUnit.assertEquals(self.object:getPropertyValue("acf/_min_n1"), "12.0")
    luaUnit.assertEquals(
        self.object:getPropertyValue("acf/_author"),
        "Test Author - https://github.com/VerticalLongboard"
    )
    luaUnit.assertEquals(self.object:getPropertyValue("bla"), nil)
end
