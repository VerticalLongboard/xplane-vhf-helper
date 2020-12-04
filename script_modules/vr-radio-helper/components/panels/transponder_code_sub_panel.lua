local Globals = require("vr-radio-helper.globals")
local Datarefs = require("vr-radio-helper.state.datarefs")
local NumberSubPanel = require("vr-radio-helper.components.panels.number_sub_panel")
local SpeakNato = require("vr-radio-helper.components.speak_nato")
local Config = require("vr-radio-helper.state.config")

local TransponderCodeSubPanel
do
	TransponderCodeSubPanel = NumberSubPanel:new()

	Globals.OVERRIDE(TransponderCodeSubPanel.new)
	function TransponderCodeSubPanel:new(
		newValidator,
		transponderCodeLinkedDataref,
		transponderModeLinkedDataref,
		newPanelTitle,
		newDescriptor)
		local newInstanceWithState = NumberSubPanel:new(newPanelTitle, newValidator)

		newInstanceWithState.Constants.FullyPaddedString = "----"

		newInstanceWithState.codeDataref = transponderCodeLinkedDataref
		newInstanceWithState.modeDataref = transponderModeLinkedDataref
		newInstanceWithState.descriptor = newDescriptor

		setmetatable(newInstanceWithState, self)
		self.__index = self
		return newInstanceWithState
	end

	Globals.OVERRIDE(TransponderCodeSubPanel.addCharacter)
	function TransponderCodeSubPanel:addCharacter(character)
		if (self.enteredValue:len() == 4) then
			return
		end

		self.enteredValue = self.enteredValue .. character
	end

	Globals.OVERRIDE(TransponderCodeSubPanel.numberCanBeSetNow)
	function TransponderCodeSubPanel:numberCanBeSetNow()
		return (self.enteredValue:len() > 0)
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._setLinkedValue)
	function TransponderCodeSubPanel:_setLinkedValue()
		local numberString = self.inputPanelValidator:autocomplete(self.enteredValue)
		local number = tonumber(numberString)
		self.codeDataref:emitNewValue(number)
		if (Config.Config:getSpeakNumbersLocally()) then
			SpeakNato.speakTransponderCode(numberString)
		end
		self.enteredValue = Globals.emptyString
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._getCurrentLinkedValueString)
	function TransponderCodeSubPanel:_getCurrentLinkedValueString()
		local str = tostring(self.codeDataref:getLinkedValue())
		for i = str:len(), 3 do
			str = "0" .. str
		end
		return str
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._buildModeButtonLine)
	function TransponderCodeSubPanel:_buildModeButtonLine()
		imgui.SetWindowFontScale(0.8 * globalFontScale)
		imgui.Dummy(8.0, 0.0)
		imgui.SameLine()
		imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 4.0, 0.0)
		imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

		for m = 0, #Datarefs.transponderModeToDescriptor - 1 do
			self:_renderOneModeButton(m)
			imgui.SameLine()
		end

		imgui.PopStyleVar()
		imgui.PopStyleVar()
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._renderOneModeButton)
	function TransponderCodeSubPanel:_renderOneModeButton(mode)
		Globals.ImguiUtils.renderActiveInactiveButton(
			Datarefs.transponderModeToDescriptor[mode + 1],
			self.modeDataref:getLinkedValue() == mode,
			true,
			function()
				self.modeDataref:emitNewValue(mode)
			end,
			self:_getBlinkingCurrentValueColor(self.modeDataref)
		)
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._buildCurrentTransponderLine)
	function TransponderCodeSubPanel:_buildCurrentTransponderLine(nextValueIsSettable)
		imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

		imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.greyText)
		imgui.SetWindowFontScale(0.5 * globalFontScale)
		imgui.TextUnformatted("\n   TRANSPONDER ")
		imgui.PopStyleColor()

		imgui.SameLine()
		imgui.SetWindowFontScale(1.0 * globalFontScale)
		self:_pushBlinkingCurrentValueColor(self.codeDataref)

		imgui.TextUnformatted(
			self.inputPanelValidator:validate(self:_getCurrentLinkedValueString()) or self.Constants.FullyPaddedString
		)
		imgui.PopStyleColor()

		imgui.SameLine()
		imgui.TextUnformatted(" ")

		Globals.ImguiUtils.pushSwitchButtonColors(nextValueIsSettable)
		if (nextValueIsSettable) then
			imgui.SameLine()
			if (imgui.Button("<X>")) then
				self:_setLinkedValue()
			end
		end
		Globals.ImguiUtils.popSwitchButtonColors()

		imgui.PopStyleVar()
	end

	Globals.OVERRIDE(TransponderCodeSubPanel.renderToCanvas)
	function TransponderCodeSubPanel:renderToCanvas()
		imgui.SetWindowFontScale(1.0 * globalFontScale)

		local nextValueIsSettable = self:numberCanBeSetNow()

		imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)
		imgui.Dummy(0.0, 3.0)

		self:_buildCurrentTransponderLine(nextValueIsSettable)
		self:_buildModeButtonLine()

		imgui.SetWindowFontScale(1.0 * globalFontScale)
		imgui.TextUnformatted(" ")
		imgui.Dummy(0.0, 28.0)
		imgui.Separator()

		imgui.TextUnformatted("        ")

		imgui.SetWindowFontScale(1.0 * globalFontScale)
		Globals.ImguiUtils.pushNextValueColor(nextValueIsSettable)
		imgui.SameLine()
		local paddedString = self.enteredValue .. self.Constants.FullyPaddedString:sub(string.len(self.enteredValue) + 1, 4)
		imgui.TextUnformatted(paddedString)

		imgui.PopStyleVar()

		imgui.PopStyleColor()

		imgui.Separator()
		self:_renderNumberPanel()
	end
end

return TransponderCodeSubPanel
