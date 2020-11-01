# VHF Helper Developer Notes

## Development Environment
If you happen to develop FlyWithLua plugins and are crossing the threshold from "coding a bit and pressing buttons to see if my plugin works" to "I don't like LUA too much, but it's doing its job and I like to code a bit more", feel free to use and adapt the VS Code / LuaUnit environment boilerplate from VHF Helper.

Perks:
* Linting and colors while coding
* Testing as you're used to
* Pressing "Build" runs all tests, copies the script to X-Plane and triggers a running X-Plane instance to reload all scripts
* Building a release package is only one button away (ZIP + Installer)

### Setup
Required:
* Vanilla Windows 10
* Visual Studio Code: https://code.visualstudio.com/
* Install Lua: https://github.com/rjpcomputing/luaforwindows
* Update paths in `build/configure_environment.cmd`

Optional:
* git: https://git-scm.com/
* Install 7zip: https://www.7-zip.org/
* Install NSIS: https://nsis.sourceforge.io/
* Install Packetsender: https://packetsender.com/
* Install VS Code extensions:
  * vscode-lua (linting): https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua
  * Code Runner (lets you run selected snippets of code): https://marketplace.visualstudio.com/items?itemName=formulahendry.code-runner
* Update paths in `build/configure_environment.cmd`

Clone the VHF Helper repository and open the workspace in VS Code!

## Public API
VHF Helper offers a public API via a global `VHFHelperPublicInterface` while its panel is visible:
```text
if (VHFHelperPublicInterface ~= nil) then
	-- Call method on VHFHelperPublicInterface
	...
end
```

Programmatically set the `Next VHF` frequency in VHF Helper's panel (returns `nil` if invalid):
```text
VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString("124.800")
```

Find out if a frequency is currently tuned in (returns `true/false`):
```text
VHFHelperPublicInterface.isCurrentlyTunedIn("120.500")
```

Find out if a frequency is the same as the currently entered `Next VHF` (returns `true/false`):
```text
VHFHelperPublicInterface.isCurrentlyEntered("119.250")
```

Find out if a frequency is valid (returns `true/false`):
```text
VHFHelperPublicInterface.isValidFrequency("199x998")
```

Only valid default VHF airband frequencies are accepted (118.000 to 136.975) and reported equal, with one **exception**: If the last digit doesn't match the default airband exactly, it is replaced by either a "0" or "5" based on whatever makes more sense. Any completely invalid, i.e. out-of-range, frequency is ignored and, in case of `enterFrequencyProgrammaticallyAsString`, the next VHF frequency currently entered is cleared.

VHF Helper uses an Event Bus to emit any changes (even when its panel is not visible) in:
* tuned-in frequencies (`COM1` or `COM2`)
* currently entered frequencies (`Next VHF`)

Use the `VHFHelperEventOnFrequencyChanged` event to listen:
```text
function onFrequencyChanged()
	-- Do something when frequencies change
	...
end

-- Start listening for changes
VHFHelperEventBus.on(VHFHelperEventOnFrequencyChanged, onFrequencyChanged)

-- Stop listening
VHFHelperEventBus.off(VHFHelperEventOnFrequencyChanged, onFrequencyChanged)
```
