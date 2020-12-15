# VR Radio Helper (aka VHF Helper)
## Overview
VR Radio Helper is a FlyWithLua plugin for X-Plane 11. It allows to change the two main COM frequencies of any X-Plane airplane in **Virtual Reality** via convenient touch pad number buttons in a **multicrew** environment. For many default airplanes, NAV, Transponder and Barometer can be changed as well.

Flying VR multicrew in X-Plane with ATC is a blast! Yet, the default X-Plane 11 VR knobs are horrible when trying to monitor/fly and dial in a new ATC frequency at the same time (takes up to 2 minutes for a 2-hour flight, just turning the knob and making sure that no turn got lost when using SmartCopilot).

VR Radio Helper:
* Makes tuning in a new ATC frequency a breeze!
  * It replaces most ATC/navigation-related knobs with a number panel, like **COM, NAV, Transponder and Barometer** settings.
* Works with SmartCopilot, syncrhonizing COM/NAV frequencies, transponder codes and barometer settings between **two pilots**
  * Both pilots need to install SmartCopilot
  * Required changes to an existing SmartCopilot installation are applied automatically.
* Works in VR (free positioning in 3D space)
* Integrates well with ATC networks (e.g. VATSIM), showing **ATC station names** and a **Real-Time Radar**

![VR Radio Helper Screenshot](screenshots/VHFHelperScreenshot2.png "VHF Helper Screenshot")

## Installation
* Install FlyWithLua: https://forums.x-plane.org/index.php?/files/file/38445-flywithlua-ng-next-generation-edition-for-x-plane-11-win-lin-mac/
* Download [latest release](https://github.com/VerticalLongboard/xplane-vhf-helper/releases/latest)
* *Use installer executable* and specify your X-Plane installation folder or unzip manually (including subfolders):
  * Move dependencies from `Modules` to `<X-Plane 11 Folder>/Resources/plugins/FlyWithLua/Modules`
  * Move script files and data from `Scripts` to `<X-Plane 11 Folder>/Resources/plugins/FlyWithLua/Scripts`

To make it multicrew-ready (do that in **BOTH** pilot's airplanes):
* Install SmartCopilot: https://sky4crew.com/smartcopilot/ and install aircraft-specific `smartcopilot.cfg`

To see ATC station information and real-time radar positions:
* Install Vatsimbrief Helper: https://github.com/RedXi/vatsimbrief-helper

## Usage
* Go to `Plugins/FlyWithLua/FlyWithLua Macros/VR Radio Helper`.
* Place and scale the panel wherever you like (in 2D and VR).
* Use the number buttons to enter the new VHF frequency. The last two digits do not need to be entered manually.
* Press `NAV`, `TP` or `BARO` to change to NAV, Transponder and Barometer panels.
* Press the corresponding switch button to tune in new frequencies, transponder codes or barometer pressures.
* **Chat with ATC! :-)**
* If you like, bind the toggle-panel command `FlyWithLua/VR Radio Helper/TogglePanel` to a key of your choice.

For ATC Station Names and Radar:
* Install Vatsimbrief Helper
* Check if Vatsim data transfer is available via clicking the `>` button
* As long as Vatsimbrief Helper is installed and able to access Vatsim Data, you will see:
  * ATC station names and short description for tuned-in or entered frequencies
  * All Vatsim clients close to your current location in `Radar`

For multicrew:
 * Install SmartCopilot
 * Check if multicrew support is available via clicking the `>` button
 * If something doesn't work yet, you'll get notified and will find more information in the options panel.
 * Connect via SmartCopilot
 * If SmartCopilot was installed and reconfigured correctly, entered freqencies, pressures and codes will be synchronized between two pilots

## Plane Compatibility
VR Radio Helper uses the default X-Plane way of setting COM/NAV frequencies, barometer pressures and transponder codes. By default, all features are enabled. If you find that this does not work out-of-the-box in your plane, please use the integrated feedback collector (click the `>` button) to leave a description of the issues that you encountered. The plane compatibility reports automatically generate diagnostic information that is necessary to distinguish between different planes.
Based on this information, a growing number of planes are detected automatically and settings adjusted / features disabled accordingly.

## Dependencies
Additional dependencies besides X-Plane 11, SmartCopilot and FlyWithLua:
- LUA INI Parser
- LUA Event Bus

(All dependencies are bundled with each release)

## Developer Notes
You want to integrate VR Radio Helper into other plugins? See [VR Radio Helper Public Interface](PUBLIC-INTERFACE.md) or [Vatsimbrief Helper](https://github.com/RedXi/vatsimbrief-helper) to see it in action.

Looking for a good starting point to write your own FlyWithLua plugins? Have a look at the [A320 NORMAL CHECKLIST Developer Notes](https://github.com/VerticalLongboard/xplane-a320-checklist/blob/main/DEVELOPMENT_ENVIRONMENT.md)!
