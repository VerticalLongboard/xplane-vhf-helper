local Globals = {
    emptyString = "",
    decimalCharacter = ".",
    underscoreCharacter = "_",
    readableScriptName = "VR Radio Helper",
    sidePanelName = "VR Radio Helper Feedback and Settings"
}

TRACK_ISSUE = TRACK_ISSUE or function(component, description, workaround)
    end

MULTILINE_TEXT = MULTILINE_TEXT or function(...)
    end

Globals.pushDefaultButtonColorsToImguiStack = function()
    local slightlyBrighterDefaultButtonColor = 0xFF7F5634
    imgui.PushStyleColor(imgui.constant.Col.ButtonActive, Globals.Colors.defaultImguiButtonBackground)
    imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, slightlyBrighterDefaultButtonColor)
end

Globals.popDefaultButtonColorsFromImguiStack = function()
    imgui.PopStyleColor()
    imgui.PopStyleColor()
end

Globals.requireAllAndBootstrap = function(luaRequireStringTable)
    for _, luaRequireString in pairs(luaRequireStringTable) do
        local requiredScript = require(luaRequireString)
        requiredScript.bootstrap()
    end
end

Globals.prefixAllLines = function(linesString, prefix)
    return prefix .. linesString:gsub("\n", "\n" .. prefix)
end

Globals.fileExists = function(filePath)
    local file = io.open(filePath, "r")
    if file == nil then
        return false
    end

    io.close(file)
    return true
end

Globals.printLogMessage = function(messageString)
    logMsg(("%s: %s"):format(Globals.readableScriptName, messageString or "NIL"))
end

local licensesOfDependencies = {
    {
        "Lua INI Parser",
        "MIT License",
        "https://github.com/Dynodzzo/Lua_INI_Parser"
    },
    {
        "Lua Event Bus",
        "MIT License",
        "https://github.com/prabirshrestha/lua-eventbus"
    },
    {"LuaUnit", "BSD License", "https://github.com/bluebird75/luaunit"},
    {"FlyWithLua", "MIT License", "https://github.com/X-Friese/FlyWithLua"}
}
for i = 1, #licensesOfDependencies do
    Globals.printLogMessage(
        ("Using '%s' with license '%s'. Project homepage: %s"):format(
            licensesOfDependencies[i][1],
            licensesOfDependencies[i][2],
            licensesOfDependencies[i][3]
        )
    )
end

Globals.trim = function(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

Globals.replaceCharacter = function(str, pos, newCharacter)
    return str:sub(1, pos - 1) .. newCharacter .. str:sub(pos + 1)
end

Globals.OVERRIDE = function(overriddenFunction)
    assert(overriddenFunction)
end

Globals._NEWFUNC = function(overriddenFunction)
    assert(overriddenFunction == nil)
end

Globals.windowVisibilityToInitialMacroState = function(windowIsVisible)
    if windowIsVisible then
        return "activate"
    else
        return "deactivate"
    end
end

Globals.windowVisibilityVisible = "visible"
Globals.windowVisibilityHidden = "hidden"

Globals.globalFontScale = nil
Globals.defaultDummySize = nil

Globals.Colors = {
    a320Orange = 0xFF00AAFF,
    a320Blue = 0xFFFFDDAA,
    a320Green = 0xFF00AA00,
    white = 0xFFFFFFFF,
    black = 0xFF000000,
    defaultImguiBackground = 0xFF121110,
    defaultImguiButtonBackground = 0xFF6F4624
}

local ImguiUtils
do
    ImguiUtils = {}
    function ImguiUtils:renderActiveInactiveButton(buttonTitle, active, onPressFunction)
        if (active) then
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
        end

        if (imgui.Button(buttonTitle)) then
            onPressFunction()
        end

        imgui.PopStyleColor()
    end
end

Globals.ImguiUtils = ImguiUtils

return Globals
