imgui = {
    constant = {
        StyleVar = {
            ItemSpacing
        },
        Col = {
            Text,
            Button
        }
    },
    SetWindowFontScale = function(value)
    end,
    PushStyleVar_2 = function(value, value2)
    end,
    PopStyleVar = function()
    end,
    TextUnformatted = function(value)
        imgui:checkStringForWatchStrings(value)
    end,
    PushStyleColor = function(value)
    end,
    SameLine = function()
    end,
    PopStyleColor = function()
    end,
    Dummy = function(value1, value2)
    end,
    Button = function(value)
        imgui:checkStringForWatchStrings(value)
        if (value == imgui.pressButtonWithThisTitleProgrammatically) then
            imgui.buttonPressed = true
            return true
        end

        return false
    end
}

function imgui:checkStringForWatchStrings(value)
    if (imgui.watchString ~= nil and value:find(imgui.watchString)) then
        imgui.watchStringFound = true
    end

    if (value == imgui.exactMatchString) then
        imgui.exactMatchFound = true
    end
end

function imgui:startFrame()
    self.watchStringFound = false
    self.exactMatchFound = false
    self.buttonPressed = false
end

function imgui:pressButtonProgrammaticallyOnce(buttonTitle)
    self.pressButtonWithThisTitleProgrammatically = buttonTitle
end

function imgui:keepALookOutForString(someString)
    self.watchString = someString
end

function imgui:keepALookOutForExactMatch(someString)
    self.exactMatchString = someString
end

function imgui:endFrame()
    self.pressButtonWithThisTitleProgrammatically = nil
end

function imgui:wasWatchStringFound()
    return self.watchStringFound
end

function imgui:wasExactMatchFound()
    return self.exactMatchFound
end

function imgui:wasButtonPressed()
    return self.buttonPressed
end

return imgui
