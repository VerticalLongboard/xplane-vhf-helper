local Validation = require("vhf_helper.state.validation")
local Globals = require("vhf_helper.globals")
require("vhf_helper.components.interchange_linked_dataref")

-- FlyWithLua Issue: Pre-defined dataref handles cannot be in a table :-/
InterchangeCOM1Frequency = 0
InterchangeCOM2Frequency = 0
InterchangeNAV1Frequency = 0
InterchangeNAV2Frequency = 0
InterchangeTransponderCode = 0
InterchangeTransponderMode = 0

COM1FrequencyRead = 0
COM2FrequencyRead = 0
NAV1FrequencyRead = 0
NAV2FrequencyRead = 0
TransponderCodeRead = 0
TransponderModeRead = 0

local function isFrequencyValueValid(ild, validator, newValue)
    -- FlyWithLua Issue:
    -- After creating a shared new dataref (and setting its inital value) the writable dataref variable is being assigned a
    -- random value (very likely straight from memory) after waiting a few frames.
    -- To workaround, ignore invalid values and continue using local COM frequency values (which are supposed to be valid at this time).
    local freqString = tostring(newValue)
    local freqFullString = freqString:sub(1, 3) .. Globals.decimalCharacter .. freqString:sub(4, 6)
    if (not validator:validate(freqFullString)) then
        Globals.printLogMessage(
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

local onComLinkedChanged = function(ild, newLinkedValue)
    VHFHelperEventBus.emit(VHFHelperEventOnFrequencyChanged)
end

local isNewComFrequencyValid = function(ild, newValue)
    return isFrequencyValueValid(ild, Validation.comFrequencyValidator, newValue)
end

local isNewNavFrequencyValid = function(ild, newValue)
    return isFrequencyValueValid(ild, Validation.navFrequencyValidator, newValue)
end

local isNewTransponderCodeValid = function(ild, newValue)
    if (newValue < 0 or newValue > Validation.transponderCodeValidator.Constants.MaxTransponderCode) then
        return false
    end
end

local transponderModeToDescriptor = {}
table.insert(transponderModeToDescriptor, "OFF")
table.insert(transponderModeToDescriptor, "STBY")
table.insert(transponderModeToDescriptor, "ON")
table.insert(transponderModeToDescriptor, "ALT2")
table.insert(transponderModeToDescriptor, "ALT3")

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
        printLogMessage(
            ("Invalid transponder code=%s received. Will not update local transponder mode."):format(tostring(newValue))
        )
        return false
    end

    return true
end

local M = {}
M.transponderModeToDescriptor = transponderModeToDescriptor
M.bootstrap = function()
    M.COMLinkedDatarefs = {
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeCOM1Frequency",
            "InterchangeCOM1Frequency",
            "sim/cockpit2/radios/actuators/com1_frequency_hz_833",
            "COM1FrequencyRead",
            onNotRequiredCallbackFunction,
            onComLinkedChanged,
            isNewComFrequencyValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeCOM2Frequency",
            "InterchangeCOM2Frequency",
            "sim/cockpit2/radios/actuators/com2_frequency_hz_833",
            "COM2FrequencyRead",
            onNotRequiredCallbackFunction,
            onComLinkedChanged,
            isNewComFrequencyValid
        )
    }
    M.NAVLinkedDatarefs = {
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeNAV1Frequency",
            "InterchangeNAV1Frequency",
            "sim/cockpit2/radios/actuators/nav1_frequency_hz",
            "NAV1FrequencyRead",
            onNotRequiredCallbackFunction,
            onNotRequiredCallbackFunction,
            isNewNavFrequencyValid
        ),
        InterchangeLinkedDataref:new(
            InterchangeLinkedDataref.Constants.DatarefTypeInteger,
            "VHFHelper/InterchangeNAV2Frequency",
            "InterchangeNAV2Frequency",
            "sim/cockpit2/radios/actuators/nav2_frequency_hz",
            "NAV2FrequencyRead",
            onNotRequiredCallbackFunction,
            onNotRequiredCallbackFunction,
            isNewNavFrequencyValid
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
        onNotRequiredCallbackFunction,
        onNotRequiredCallbackFunction,
        isNewTransponderCodeValid
    )
    M.allLinkedDatarefs = {
        M.COMLinkedDatarefs[1],
        M.COMLinkedDatarefs[2],
        M.NAVLinkedDatarefs[1],
        M.NAVLinkedDatarefs[2],
        M.TransponderCodeLinkedDataref,
        M.TransponderModeLinkedDataref
    }
end
return M
