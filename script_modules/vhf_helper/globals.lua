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

Globals.requireAllAndBootstrapInOrder = function(luaRequireStringTable)
    for _, luaRequireString in pairs(luaRequireStringTable) do
        local requiredScript = require(luaRequireString)
        requiredScript.bootstrap()
    end
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
    a320Red = 0xFF4444FF,
    white = 0xFFFFFFFF,
    black = 0xFF000000,
    greyText = 0xFFAAAAAA,
    defaultImguiBackground = 0xFF121110,
    defaultImguiButtonBackground = 0xFF6F4624
}

local ImguiUtils
do
    ImguiUtils = {}
    function ImguiUtils:renderActiveInactiveButton(buttonTitle, active, enabled, onPressFunction)
        if (enabled) then
            if (active) then
                imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
            else
                imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
            end
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF444444)
            ImguiUtils:pushDisabledButtonColors()
        end

        if (imgui.Button(buttonTitle) and enabled) then
            onPressFunction()
        end

        if (not enabled) then
            ImguiUtils:popDisabledButtonColors()
        end
        imgui.PopStyleColor()
    end

    function ImguiUtils:pushDisabledButtonColors()
        imgui.PushStyleColor(imgui.constant.Col.Button, 0xFF222222)
        imgui.PushStyleColor(imgui.constant.Col.ButtonActive, 0xFF222222)
        imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, 0xFF222222)
    end

    function ImguiUtils:popDisabledButtonColors()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end
end

Globals.ImguiUtils = ImguiUtils

return Globals
