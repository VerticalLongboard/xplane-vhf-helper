## VHF Helper Public Interface
VHF Helper offers a public API via a global `VHFHelperPublicInterface` while its panel is visible:
```text
if (VHFHelperPublicInterface ~= nil) then
	-- Call method on VHFHelperPublicInterface
	...
end
```

Programmatically set the `Next VHF` frequency in VHF Helper's panel (returns `nil` if invalid):
```text
VHFHel1erPublicInterface.enterFrequencyProgrammaticallyAsString("124.800")
```

Find out if a frequency is currently tuned in, in either `COM1` or `COM2` (returns `true/false`):
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
