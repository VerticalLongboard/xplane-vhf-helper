## VR Radio Helper Interface
VR Radio Helper (formerly known as VHF Helper) offers a public API via a global `VHFHelperPublicInterface` while its panel is visible:
```text
if (VHFHelperPublicInterface ~= nil) then
	if (VHFHelperPublicInterface.getInterfaceVersion() == 1) then
		-- Setup event listener
		...
		-- Call method on VHFHelperPublicInterface
		...
		
	end
end
```

Programmatically set the `Next VHF` frequency in VHF Helper's panel (returns `nil` if invalid):
```text
VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString("124.8")
VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString("123.950")
VHFHelperPublicInterface.enterFrequencyProgrammaticallyAsString("119.70")
```

Find out if a frequency is currently tuned in, in either `COM1` or `COM2` (returns `true/false`):
```text
VHFHelperPublicInterface.isCurrentlyTunedIn("120.5")
VHFHelperPublicInterface.isCurrentlyTunedIn("132.45")
VHFHelperPublicInterface.isCurrentlyTunedIn("131.200")
```

Find out if a frequency is the same as the currently entered `Next COM` (returns `true/false`):
```text
VHFHelperPublicInterface.isCurrentlyEntered("119.25")
```

Find out if a frequency is valid (returns `true/false`):
```text
VHFHelperPublicInterface.isValidFrequency("199x998")
```

Only valid default VHF communication airband frequencies are accepted (`118.0` to `136.975`) and reported equal, with one **exception**: If the last digit doesn't match the default airband exactly, it is replaced by either a "0" or "5" based on whatever makes more sense. Any completely invalid, i.e. out-of-range, frequency is ignored and, in case of `enterFrequencyProgrammaticallyAsString`, the next COM frequency currently entered is cleared.

VHF Helper uses an Event Bus to emit any changes (even when its panel is not visible) in:
* tuned-in frequencies (`COM1` or `COM2`)
* currently entered frequencies (`Next COM`)

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
