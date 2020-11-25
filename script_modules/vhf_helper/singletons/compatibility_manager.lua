local AircraftCompatibilityId = require("vhf_helper.components.aircraft_compatibility_id")

local vhfHelperCompatibilityManagerSingleton
do
    vhfHelperCompatibilityManager = {}

    function vhfHelperCompatibilityManager:_reset()
        self.planeCompatibilityId = nil
        self.CompatibilityIdToConfiguration = {}
        self.currentConfiguration = nil
    end

    function vhfHelperCompatibilityManager:bootstrap()
        self:_reset()

        self.planeCompatibilityId = AircraftCompatibilityId:new()
        logMsg(("Plane Compatibility: Current plane id string=%s"):format(self.planeCompatibilityId:getIdString()))
        self:_addFlightFactorA320Ultimate()

        for cid, configuration in pairs(self.CompatibilityIdToConfiguration) do
            if (cid == self.planeCompatibilityId:getIdString()) then
                self.currentConfiguration = configuration
                logMsg(("Plane Compatibility: Detected plane=%s"):format(self.currentConfiguration.readableName))
                break
            end
        end

        if (self.currentConfiguration == nil) then
            self.currentConfiguration = self:_getDefaultConfiguration()
            self.currentConfiguration.isDefaultPlane = true
            logMsg(("Plane Compatibility: Using default plane=%s"):format(self.currentConfiguration.readableName))
        end
    end

    function vhfHelperCompatibilityManager:getCurrentAircraftBaseDirectory()
        return AIRCRAFT_PATH
    end

    function vhfHelperCompatibilityManager:getPlaneCompatibilityIdString()
        return self.planeCompatibilityId:getIdString()
    end

    function vhfHelperCompatibilityManager:getCurrentConfiguration()
        return self.currentConfiguration
    end

    function vhfHelperCompatibilityManager:_addConfigurationForId(id, configuration)
        if (self.CompatibilityIdToConfiguration[id] ~= nil) then
            logMsg(("Plane Compatibility: WARNING: Overwriting compatibility configuration for plane id=%s"):format(id))
        end
        self.CompatibilityIdToConfiguration[id] = configuration
    end

    function vhfHelperCompatibilityManager:_addFlightFactorA320Ultimate()
        local newConfiguration = self:_getDefaultConfiguration()
        newConfiguration.readableName = "FlightFactor Airbus A320 Ultimate"
        self:_addKnownIssuesToConfiguration(newConfiguration, "NAV and Transponder do not work and are disabled.")
        newConfiguration.isNavFeatureEnabled = false
        newConfiguration.isTransponderFeatureEnabled = false
        self:_addConfigurationForId(
            "ICAO:A320:TAILNUMBER:D-AXLA:ACF_FILE_NAME:A320.acf:ACF_DESC:FlightFactor Airbus A320-214 CFM56-5B4 ultimate:ACF_MANUFACTURER:Airbus:ACF_STUDIO:FlightFactor:ACF_AUTHOR:FlightFactor:ACF_NAME::",
            newConfiguration
        )
    end

    function vhfHelperCompatibilityManager:_addKnownIssuesToConfiguration(configuration, knownIssuesText)
        configuration.hasKnownIssues = true
        configuration.knownIssuesText = knownIssuesText
    end

    function vhfHelperCompatibilityManager:_getDefaultConfiguration()
        return {
            hasKnownIssues = false,
            readableName = "Default Plane",
            isNavFeatureEnabled = true,
            isTransponderFeatureEnabled = true
        }
    end
end

local M = {}
M.bootstrap = function()
    vhfHelperCompatibilityManager:bootstrap()
end
return M
