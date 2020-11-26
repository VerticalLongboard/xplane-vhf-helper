local Globals = require("vhf_helper.globals")
local AcfReader = require("shared_components.acf_reader")

local AircraftCompatibilityId
do
    AircraftCompatibilityId = {}

    function AircraftCompatibilityId:new()
        local newInstanceWithState = {
            icao = icao,
            acfFileName = acfFileName,
            acfPropertyDesc = acfDesc,
            acfPropertyManufacturer = acfManufacturer,
            acfPropertyStudio = acfStudio,
            acfPropertyAuthor = acfAuthor,
            acfPropertyName = acfName
        }

        setmetatable(newInstanceWithState, self)
        self.__index = self

        self:_generateIdStringNow()
        -- self:_generateIdHashNow()
        return newInstanceWithState
    end

    function AircraftCompatibilityId:getIdString()
        return self.idString
    end

    -- function AircraftCompatibilityId:getIdHash()
    --     return self.idHash
    -- end

    function AircraftCompatibilityId:_generateIdStringNow()
        local acfReader = AcfReader:new()
        local acfPath = AIRCRAFT_PATH .. AIRCRAFT_FILENAME
        if (not acfReader:loadFromFile(acfPath)) then
            logMsg(("Plane Compatibility: Aircraft file=%s could not be loaded."):format(acfPath))
        end

        self.icao = PLANE_ICAO
        self.acfFileName = AIRCRAFT_FILENAME
        self.tailnumber = PLANE_TAILNUMBER
        self.acfPropertyDesc = acfReader:getPropertyValue("acf/_descrip")
        self.acfPropertyManufacturer = acfReader:getPropertyValue("acf/_manufacturer")
        self.acfPropertyStudio = acfReader:getPropertyValue("acf/_studio")
        self.acfPropertyAuthor = acfReader:getPropertyValue("acf/_author")
        self.acfPropertyName = acfReader:getPropertyValue("acf/_name")

        local NoInfoMarker = ":"

        self.idString =
            ("ICAO:%s:TAILNUMBER:%s:ACF_FILE_NAME:%s:ACF_DESC:%s:ACF_MANUFACTURER:%s:ACF_STUDIO:%s:ACF_AUTHOR:%s:ACF_NAME:%s"):format(
            self.icao,
            self.tailnumber,
            self.acfFileName,
            self.acfPropertyDesc or NoInfoMarker,
            self.acfPropertyManufacturer or NoInfoMarker,
            self.acfPropertyStudio or NoInfoMarker,
            self.acfPropertyAuthor or NoInfoMarker,
            self.acfPropertyName or NoInfoMarker
        )
    end

    -- function AircraftCompatibilityId:_generateIdHashNow()
    --     self.idHash = MD5.sumhexa(self.idString)
    -- end
end

return AircraftCompatibilityId
