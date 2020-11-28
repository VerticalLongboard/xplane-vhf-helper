local Validation = require("vhf_helper.state.validation")
local Globals = require("vhf_helper.globals")
local InterchangeLinkedDataref = require("vhf_helper.components.interchange_linked_dataref")
local SpeakNato = require("vhf_helper.components.speak_nato")
local Config = require("vhf_helper.state.config")
local Utilities = require("shared_components.utilities")

TRACK_ISSUE(
    "FlyWithLua",
    "Pre-defined dataref handles cannot be in a table :-/",
    "Declare global dataref variables outside any table and give them a long enough name."
)
InterchangeCOM1Frequency = 0
InterchangeCOM2Frequency = 0
InterchangeNAV1Frequency = 0
InterchangeNAV2Frequency = 0
InterchangeTransponderCode = 0
InterchangeTransponderMode = 0
InterchangeBaro1 = 0
InterchangeBaro2 = 0
InterchangeBaro3 = 0

COM1FrequencyRead = 0
COM2FrequencyRead = 0
NAV1FrequencyRead = 0
NAV2FrequencyRead = 0
TransponderCodeRead = 0
TransponderModeRead = 0
Baro1Read = 0
Baro2Read = 0
Baro3Read = 0

TRACK_ISSUE(
    "FlyWithLua",
    MULTILINE_TEXT(
        "After creating a shared new dataref (and setting its inital value) the writable dataref variable is being assigned",
        "a random value (very likely straight from memory) after waiting a few frames."
    ),
    "Ignore invalid values and continue using locally available values (which are supposed to be valid at this time)."
)
local function isFrequencyValueValid(ild, validator, newValue)
    local freqString = tostring(newValue)
    local freqFullString = freqString:sub(1, 3) .. Globals.decimalCharacter .. freqString:sub(4, 6)
    if (not validator:validate(freqFullString)) then
        logMsg(
            ("Warning: Interchange variable %s has been externally assigned an invalid value=%s. " ..
                "This is very likely happening during initialization and is a known issue in FlyWithLua/X-Plane dataref handling. " ..
                    "If this happens during flight, something is seriously wrong."):format(
                ild.interchangeDatarefName,
                freqFullString
            )
        )
        return false
    end

    return true
end

local onNotRequiredCallbackFunction = function(ild, newValue)
end

local onInterchangeBarometerChanged = function(ild, value)
    if (Config.Config:getSpeakRemoteNumbers() == true) then
        local hPa = Utilities.roundFloatingPointToNearestInteger(Globals.convertHgToHpa(value))
        local str = tostring(hPa)
        SpeakNato.speakQnh(str)
    end
end

local onInterchangeFrequencyChanged = function(ild, newValue)
    if (Config.Config:getSpeakRemoteNumbers() == true) then
        local freqString = tostring(newValue)
        local freqFullString = freqString:sub(1, 3) .. Globals.decimalCharacter .. freqString:sub(4, 6)
        SpeakNato.speakFrequency(freqFullString)
    end
end

local onInterchangeTransponderCodeChanged = function(ild, newValue)
    if (Config.Config:getSpeakRemoteNumbers() == true) then
        local codeString = tostring(newValue)
        for i = codeString:len(), 3 do
            codeString = "0" .. codeString
        end
        SpeakNato.speakTransponderCode(codeString)
    end
end

local onComLinkedChanged = function(ild, newValue)
    VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

local isNewBarometerValid = function(ild, newValue)
    return Validation.baroValidator:validate(tostring(Globals.convertHgToHpa(newValue))) ~= nil
end

local isNewComFrequencyValid = function(ild, newValue)
    return isFrequencyValueValid(ild, Validation.comFrequencyValidator, newValue)
end

local isNewNavFrequencyValid = function(ild, newValue)
    return isFrequencyValueValid(ild, Validation.navFrequencyValidator, newValue)
end

local isNewTransponderCodeValid = function(ild, newValue)
    return Validation.transponderCodeValidator:validate(tostring(newValue)) ~= nil
end

local transponderModeToDescriptor = {}
table.insert(transponderModeToDescriptor, "OFF")
table.insert(transponderModeToDescriptor, "STBY")
table.insert(transponderModeToDescriptor, "ON")
table.insert(transponderModeToDescriptor, "ALT")
table.insert(transponderModeToDescriptor, "TEST")

TRACK_ISSUE(
    "Plane Compatibility",
    "Default planes work well usually, but non-default planes have vastly different meanings for transponder modes."
)
local isNewTransponderModeValid = function(ild, newValue)
    -- This is based on personal observation in different airplanes:
    -- 0: OFF
    -- 1: STBY <<
    -- 2: ON/XPDR <<
    -- 3: TEST/XPDR/ALT <<
    -- 4: TEST2/XPDR
    --
    -- There's too much confusion, I can't get no relief:
    -- https://forums.x-plane.org/index.php?/forums/topic/85093-transponder_mode-datarefs-altitude-reporting-and-confusion/
    if (newValue < 0 or newValue > 4) then
        logMsg(
            ("Invalid transponder code=%s received. Will not update local transponder mode."):format(tostring(newValue))
        )
        return false
    end

    return true
end

local M = {}
M.transponderModeToDescriptor = transponderModeToDescriptor
M.bootstrap = function()
    M.comLinkedDatarefs = {
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeCOM1Frequency",
            "InterchangeCOM1Frequency",
            "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
            "COM1FrequencyRead",
            onInterchangeFrequencyChanged,
            onComLinkedChanged,
            isNewComFrequencyValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeCOM2Frequency",
            "InterchangeCOM2Frequency",
            "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
            "COM2FrequencyRead",
            onInterchangeFrequencyChanged,
            onComLinkedChanged,
            isNewComFrequencyValid
        )
    }
    M.navLinkedDatarefs = {
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeNAV1Frequency",
            "InterchangeNAV1Frequency",
            "sim/cockpit2/radios/actuators/nav1_frequency_hz",
            "NAV1FrequencyRead",
            onInterchangeFrequencyChanged,
            onNotRequiredCallbackFunction,
            isNewNavFrequencyValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeNAV2Frequency",
            "InterchangeNAV2Frequency",
            "sim/cockpit2/radios/actuators/nav2_frequency_hz",
            "NAV2FrequencyRead",
            onInterchangeFrequencyChanged,
            onNotRequiredCallbackFunction,
            isNewNavFrequencyValid
        )
    }
    M.baroLinkedDatarefs = {
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeFloat,
            "VHFHelper/InterchangeBaro1",
            "InterchangeBaro1",
            "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot",
            "Baro1Read",
            onInterchangeBarometerChanged,
            onNotRequiredCallbackFunction,
            isNewBarometerValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeFloat,
            "VHFHelper/InterchangeBaro2",
            "InterchangeBaro2",
            "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot",
            "Baro2Read",
            onInterchangeBarometerChanged,
            onNotRequiredCallbackFunction,
            isNewBarometerValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeFloat,
            "VHFHelper/InterchangeBaro3",
            "InterchangeBaro3",
            "sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby",
            "Baro3Read",
            onInterchangeBarometerChanged,
            onNotRequiredCallbackFunction,
            isNewBarometerValid
        )
    }
    M.TransponderModeLinkedDataref =
        InterchangeLinkedDataref:new(
        InterchangeLinkedDataref.Constants.DatarefTypeInteger,
        "VHFHelper/InterchangeTransponderMode",
        "InterchangeTransponderMode",
        "sim/cockpit2/radios/actuators/transponder_mode",
        "TransponderModeRead",
        onNotRequiredCallbackFunction,
        onNotRequiredCallbackFunction,
        isNewTransponderModeValid
    )
    M.TransponderCodeLinkedDataref =
        InterchangeLinkedDataref:new(
        InterchangeLinkedDataref.Constants.DatarefTypeInteger,
        "VHFHelper/InterchangeTransponderCode",
        "InterchangeTransponderCode",
        "sim/cockpit2/radios/actuators/transponder_code",
        "TransponderCodeRead",
        onInterchangeTransponderCodeChanged,
        onNotRequiredCallbackFunction,
        isNewTransponderCodeValid
    )
    M.allLinkedDatarefs = {
        M.comLinkedDatarefs[1],
        M.comLinkedDatarefs[2],
        M.navLinkedDatarefs[1],
        M.navLinkedDatarefs[2],
        M.TransponderCodeLinkedDataref,
        M.TransponderModeLinkedDataref,
        M.baroLinkedDatarefs[1],
        M.baroLinkedDatarefs[2],
        M.baroLinkedDatarefs[3]
    }
end
return M
