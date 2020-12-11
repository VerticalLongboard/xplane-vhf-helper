local Globals = require("vr-radio-helper.globals")
local Validation = require("vr-radio-helper.state.validation")
local LuaPlatform = require("lua_platform")
local Utilities = require("vr-radio-helper.shared_components.utilities")
local FlexibleLength1DSpring = require("vr-radio-helper.shared_components.flexible_length_1d_spring")

local SubPanel
do
    SubPanel = {}

    function SubPanel:new(newPanelTitle)
        local newInstanceWithState = {
            panelTitle = newPanelTitle
        }
        setmetatable(newInstanceWithState, self)
        self.__index = self
        return newInstanceWithState
    end

    function SubPanel:loop(frameTime)
    end

    function SubPanel:show()
    end

    function SubPanel:renderToCanvas()
        assert(nil)
    end
end

return SubPanel
