local vhfHelperCompatibilityManagerSingleton
do
    vhfHelperCompatibilityManager = {}

    function vhfHelperCompatibilityManager:_reset()
    end

    function vhfHelperCompatibilityManager:bootstrap()
        self:_reset()
    end

    function vhfHelperCompatibilityManager:getCurrentAircraftBaseDirectory()
        return AIRCRAFT_PATH
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperCompatibilityManager:bootstrap()
end
return M
