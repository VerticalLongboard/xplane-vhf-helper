local Utilities = require("shared_components.utilities")

TestUtilities = {}

function TestUtilities:testUrlEncodeWorks()
    luaUnit.assertEquals(
        Utilities.urlEncode(
            "https://www.bla.com/test?queryParam=With Whitespace&anotherParam=Here are\nwhitespaces too!!!"
        ),
        "https://www.bla.com/test?queryParam=With%20Whitespace&anotherParam=Here%20are%0awhitespaces%20too!!!"
    )
end

function TestUtilities:testOsExecuteEncodeWorks()
    luaUnit.assertEquals(
        Utilities.osExecuteEncode(
            "https://www.bla.com/test?queryParam=With%20Whitespace&anotherParam=Here%20are%20whitespaces%20too!!!"
        ),
        "https://www.bla.com/test?queryParam=With%20Whitespace^&anotherParam=Here%20are%20whitespaces%20too!!!"
    )
end
