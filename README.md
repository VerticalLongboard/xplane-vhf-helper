# VHF Helper

## Overview

VHF Helper is a FlyWithLua plugin for X-Plane 11. It allows to change the two main COM frequencies of any X-Plane airplane in **VR** via convenient touch pad number buttons in a **multicrew** environment.

Flying multicrew in X-Plane with ATC is a blast! Yet, the default X-Plane 11 VR knobs are horrible when trying to monitor/fly and dial in a new ATC frequency at the same time (takes up to 2 minutes for a 2-hour flight, just turning the knob and making sure that no turn got lost when using SmartCopilot).

VHF Helper:
* Makes tuning in a new ATC frequency a breeze!
* Works with SmartCopilot (both pilots need to install VHF Helper) and synchronizes COM frequencies between two pilots
* Works in VR (free positioning in 3D space)
* Integrates well with ATC networks (e.g. VATSIM)

![VHF Helper Screenshot](screenshots/VHFHelperScreenshot2.png "VHF Helper Screenshot")
![VHF Helper Video](screenshots/VHFHelperUsageVideo.gif "VHF Helper Video")

## Installation

* Install FlyWithLua: https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/
* Download [latest VHF Helper release](https://github.com/VerticalLongboard/xplane-vhf-helper/releases/latest)
* Move dependencies to `<X-Plane 11 Folder>/Resources/plugins/FlyWithLua/Modules`
* Move `vhf_helper.lua` to `<X-Plane 11 Folder>/Resources/plugins/FlyWithLua/Scripts`

To make it multicrew-ready (do that in **BOTH** pilot's airplanes):

* Install SmartCopilot: https://sky4crew.com/smartcopilot/ and install aircraft-specific `smartcopilot.cfg`
* Add the following line to `<X-Plane 11 Folder>/ ... /<Airplane folder>/smartcopilot.cfg`, under **[TRIGGERS]**
```text
[TRIGGERS]
VHFHelper/InterchangeVHF1Frequency = 0
VHFHelper/InterchangeVHF2Frequency = 0
```

## Usage

* Go to `Plugins/FlyWithLua/FlyWithLua Macros/VHF Helper`
* Place and scale the window wherever you like (in 2D and VR)
* Use the number buttons to enter the new VHF frequency. The last two digits are subject to auto completion.
* Press the COM1 or COM2 switch button to tune in the new frequency
* **Chat with ATC! :-)**

## Dependencies

Additional dependencies besides X-Plane 11, SmartCopilot and FlyWithLua:
- LUA INI Parser
- LUA Event Bus

(All dependencies are bundled with each release)

## Public API

VHF Helper offers a public API via a global `VHFHelperPublicInterface` while its panel is visible:
```text
if (VHFHelperPublicInterface ~= nil) then
	-- Call method on VHFHelperPublicInterface
	...
end
```

To programmatically set the `Next VHF` frequency in VHF Helper's panel (nil if invalid):
```text
VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString("124.800")
```

To find out if a frequency is currently tuned in (true/false):
```text
VHFHelperPublicInterface.isCurrentlyTunedIn("119.250")
```

To find out if a frequency is the same as the currently entered `Next VHF` (true/false):
```text
VHFHelperPublicInterface.isCurrentlyEntered("119.250")
```

Only valid default VHF airband frequencies are accepted (118.000 to 136.975), with one exception: If the last digit doesn't match the default airband exactly, it is replaced by either a "0" or "5" based on whatever makes more sense. Any completely invalid, i.e. out-of-range, frequency is ignored and, in case of `enterFrequencyProgrammaticallyAsString`, the next VHF frequency currently entered is cleared.

VHF Helper uses an Event Bus to emit any changes in tuned-in or currently entered frequencies (even when its panel is not visible). Use the `VHFHelperEventOnComFrequencyChanged` event to listen:
```text
function onComFrequencyChanged()
	-- Do something when frequencies change
	...
end

-- Start listening for changes
VHFHelperEventBus.on(VHFHelperEventOnComFrequencyChanged, onComFrequencyChanged)

-- Stop listening
VHFHelperEventBus.off(VHFHelperEventOnComFrequencyChanged, onComFrequencyChanged)
```
