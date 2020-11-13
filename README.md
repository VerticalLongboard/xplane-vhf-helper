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
* *Use installer executable* and specify your X-Plane installation folder or unzip manually:
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

## Developer Notes
You want to integrate VHF Helper into other plugins? See [VHF Helper Public Interface](PUBLIC-INTERFACE.md) or [Vatsimbrief Helper](https://github.com/RedXi/vatsimbrief-helper) to see it in action.

Looking for a good starting point to write your own FlyWithLua plugins? Have a look at the [A320 NORMAL CHECKLIST](https://github.com/VerticalLongboard/xplane-a320-checklist/blob/main/DEVELOPMENT_ENVIRONMENT.md)!
