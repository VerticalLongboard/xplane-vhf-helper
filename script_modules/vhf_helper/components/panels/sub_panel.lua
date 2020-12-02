local Globals = require("vhf_helper.globals")
local Validation = require("vhf_helper.state.validation")
local LuaPlatform = require("lua_platform")
local Utilities = require("shared_components.utilities")
local FlexibleLength1DSpring = require("shared_components.flexible_length_1d_spring")

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

    function SubPanel:show()
    end

    function SubPanel:renderToCanvas()
        assert(nil)
    end
end

return SubPanel
