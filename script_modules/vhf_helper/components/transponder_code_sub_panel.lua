local Globals = require("vhf_helper.globals")
local Datarefs = require("vhf_helper.state.datarefs")
local NumberSubPanel = require("vhf_helper.components.number_sub_panel")
local SpeakNato = require("vhf_helper.components.speak_nato")
local Config = require("vhf_helper.state.config")

local TransponderCodeSubPanel
do
	TransponderCodeSubPanel = NumberSubPanel:new()

	Globals.OVERRIDE(TransponderCodeSubPanel.new)
	function TransponderCodeSubPanel:new(
		newValidator,
		transponderCodeLinkedDataref,
		transponderModeLinkedDataref,
		newDescriptor)
		local newInstanceWithState = NumberSubPanel:new(newValidator)

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
		Globals.ImguiUtils:renderActiveInactiveButton(
			Datarefs.transponderModeToDescriptor[mode + 1],
			self.modeDataref:getLinkedValue() == mode,
			true,
			function()
				self.modeDataref:emitNewValue(mode)
			end
		)
	end

	Globals._NEWFUNC(TransponderCodeSubPanel._buildCurrentTransponderLine)
	function TransponderCodeSubPanel:_buildCurrentTransponderLine(nextTransponderCodeIsSettable)
		imgui.PushStyleVar_2(imgui.constant.StyleVar.FramePadding, 0.0, 0.0)

		imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.greyText)
		imgui.TextUnformatted(self.descriptor .. "     ")
		imgui.PopStyleColor()

		imgui.SameLine()
		imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)

		local currentTransponderString = self:_getCurrentLinkedValueString()
		imgui.TextUnformatted(currentTransponderString)
		imgui.PopStyleColor()

		imgui.PushStyleColor(imgui.constant.Col.Button, Globals.Colors.a320Green)

		if (nextTransponderCodeIsSettable) then
			imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.black)
		else
			imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.white)
		end

		imgui.SameLine()
		imgui.TextUnformatted(" ")

		local buttonText = "   "
		if (nextTransponderCodeIsSettable) then
			buttonText = "<X>"

			imgui.SameLine()
			if (imgui.Button(buttonText)) then
				self:_setLinkedValue()
			end
		end

		imgui.PopStyleColor()
		imgui.PopStyleColor()

		imgui.PopStyleVar()
	end

	Globals.OVERRIDE(TransponderCodeSubPanel.renderToCanvas)
	function TransponderCodeSubPanel:renderToCanvas()
		imgui.SetWindowFontScale(1.0 * globalFontScale)

		local nextTransponderCodeIsSettable = self:numberCanBeSetNow()

		imgui.PushStyleVar_2(imgui.constant.StyleVar.ItemSpacing, 0.0, 2.0)

		self:_buildCurrentTransponderLine(nextTransponderCodeIsSettable)
		self:_buildModeButtonLine()

		imgui.SetWindowFontScale(1.0 * globalFontScale)
		imgui.TextUnformatted(" ")
		imgui.Separator()

		imgui.SetWindowFontScale(1.0 * globalFontScale)

		imgui.TextUnformatted("Next " .. self.descriptor .. "    ")

		if (nextTransponderCodeIsSettable) then
			imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Orange)
		else
			imgui.PushStyleColor(imgui.constant.Col.Text, Globals.Colors.a320Blue)
		end

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
