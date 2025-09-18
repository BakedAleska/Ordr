--!nonstrict
-- @author : BakedAleska
-- @date : 09/18/2025

--------------
-- SERVICES --
--------------
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

------------
-- IMPORT --
------------
local Network = require(ReplicatedStorage.Ordr.Utils.Network)
local Lists = require(script.Parent.Lists)

---------------
-- VARIABLES --
---------------
local Player = Players.LocalPlayer
local Ordr = Player.PlayerGui:WaitForChild("Ordr") :: ScreenGui
local Main = Ordr:WaitForChild("Mainframe")

--> Local class.
local Controller = {
	Selection = "",
	Selected = 1, --> Index of the currently selected item.
	Registry = nil, --> Registry object.
	Command = "", --> Current command.
	Send = "", --> The completed string to send to the servers parser.
}

-----------------------
-- PRIVATE FUNCTIONS --
-----------------------
local function Clear_Suggestions()
	for _, Child in ipairs(Main.Suggestions:GetChildren()) do
		if Child:IsA("TextLabel") then
			Child:Destroy()
		end
	end
end

local function Create_Suggestion_Label(Fill: string)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 18)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Code
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Text = Fill
	Label.TextColor3 = Color3.fromHex("#ffffff")
	Label.Parent = Main.Suggestions

	local Padding = Instance.new("UIPadding")
	Padding.Parent = Label
	Padding.PaddingLeft = UDim.new(0.075, 0)
end

local function Make_Set_From_Array(Arr): any
	local Set = {}
	for _, V in ipairs(Arr) do
		Set[string.lower(V)] = true
	end
	return Set
end

------------------  ---
-- PUBLIC FUNCTIONS --
----------------------

function Controller:Enable(State: boolean)
	Ordr.Enabled = State
	if State then
		Main.Entry:CaptureFocus()
		Main.Entry.Text = ""
		self.Selection = ""
		self.Selected = 1 --> Reset selection.
	else
		Main.Entry:ReleaseFocus()
	end
end

function Controller:Autofill()
	local Entry = Main.Entry
	local Words = Entry.Text:split(" ")
	local LastIndex = #Words

	if LastIndex == 0 then
		return
	end

	if self.Command == "" then
		self.Command = self.Selection
	end

	local Data = self.Registry.Info[self.Command]

	if LastIndex == 1 then
		Words[1] = self.Selection
		Entry.Text = table.concat(Words, " ")

		if Data and Data.Parameters and #Data.Parameters > 0 then
			local NextParam = Data.Parameters[1]
			if NextParam and not NextParam.Optional then
				Entry.Text ..= " "
			end
		end
	else
		if Data and Data.Parameters then
			local ParamIndex = LastIndex - 1
			local Param = Data.Parameters[ParamIndex]

			if Param then
				Words[LastIndex] = self.Selection
				Entry.Text = table.concat(Words, " ")

				local NextParam = Data.Parameters[ParamIndex + 1]
				if NextParam and not NextParam.Optional then
					Entry.Text ..= " "
				end
			end
		end
	end

	Entry.CursorPosition = #Entry.Text + 1

	self:Suggest()
end

function Controller:Suggest()
	Clear_Suggestions()

	if not self.Registry or not self.Registry.Info then
		warn("[Controller] Info not loaded.")
		return
	end

	local Text = Main.Entry.Text
	local Words = Text:split(" ")
	local Matches = {}

	-- Command suggestions
	if self.Command == "" then
		if Text ~= "" then
			local LowerText = string.lower(Text)

			for CommandName, CmdData in pairs(self.Registry.Info) do
				local LowerCommand = string.lower(CommandName)

				-- Match main command by prefix
				if string.sub(LowerCommand, 1, #LowerText) == LowerText then
					table.insert(Matches, CommandName)
					Create_Suggestion_Label(CommandName)
				end

				-- Match aliases only if fully typed
				if CmdData.Aliases then
					for _, Alias in ipairs(CmdData.Aliases) do
						if LowerText == string.lower(Alias) then
							table.insert(Matches, CommandName) -- always show canonical command
							Create_Suggestion_Label(CommandName)
						end
					end
				end
			end
		end
	else
		-- Suggest lists if command has parameters
		local Cmd = self.Registry.Info[self.Command]
		if not Cmd then
			warn("[Controller] No such matching command.")
			return
		end

		if Cmd.Parameters and #Cmd.Parameters > 0 then
			local Parameter = Cmd.Parameters[#Words - 1]

			-- Validate previous argument
			if Cmd.Parameters[#Words - 2] then
				local Word = Words[#Words - 1]
				if not Word or Word == "" or Word:match("^%s") then
					return
				end

				local PreviousParameter = Cmd.Parameters[#Words - 2]
				if PreviousParameter and PreviousParameter.List then
					local List = Make_Set_From_Array(Lists[PreviousParameter.List]())
					if not List[string.lower(Word)] then
						return
					end
				end
			end

			-- Suggest from list
			if Parameter then
				table.clear(Matches)

				-- Add list items if List exists
				if Parameter.List then
					local List = Lists[Parameter.List]()
					for _, Possible in pairs(List) do
						table.insert(Matches, Possible)
						Create_Suggestion_Label(Possible)
					end
				end

				-- Add alternates if Alternate exists
				if Parameter.Alternate then
					for _, Alt in ipairs(Parameter.Alternate) do
						table.insert(Matches, Alt)
						Create_Suggestion_Label(Alt)
					end
				end
			end
		end
	end

	if #Matches > 0 then
		self:Select(1)
	end

	-- Match a command (always last)
	if #Words > 0 then
		local LiteralCommand = Words[1]
		if self.Registry.Info[LiteralCommand] then
			self.Command = LiteralCommand
		else
			self.Command = ""
		end
	end
end

function Controller:Describe()
	local Words = Main.Entry.Text:split(" ")
	local Title
	local Description

	if #Words == 0 or Main.Entry.Text == "" then
		Main.Tooltip.Text = ""
		return
	end

	if self.Command ~= "" then
		-- Got command
		local Cmd = self.Registry.Info[self.Command]
		if not Cmd then
			warn("[Controller] No such matching command.")
			return
		end

		if Cmd.Parameters and #Cmd.Parameters > 0 then
			if #Words - 1 == 0 then
				return
			end
			local Parameter = Cmd.Parameters[#Words - 1]

			if not Parameter then
				return
			end

			Title = Parameter.Name
			Description = Parameter.Description
		end
	else
		local Selected = self.Registry.Info[self.Selection]

		if not Selected then
			return
		end

		Title = self.Selection
		Description = Selected.Description
	end

	Main.Tooltip.Text =
		string.format('<font size="18">%s</font>\n<font size="12">%s</font>', Title .. ": " or "", Description or "")
end

function Controller:Select(Index: number)
	local Labels = {}
	for _, Label in ipairs(Main.Suggestions:GetChildren()) do
		if Label:IsA("TextLabel") then
			table.insert(Labels, Label)
		end
	end

	if #Labels == 0 then
		self.Selected = 1
		self.Selection = ""
		return
	end

	Index = math.clamp(Index, 1, #Labels)

	for _, Label in ipairs(Labels) do
		Label.BackgroundTransparency = 1
	end

	local Selected = Labels[Index]
	if Selected then
		Selected.BackgroundTransparency = 0.5
		Selected.BackgroundColor3 = Color3.fromHex("#2c2d3b")
		self.Selection = Selected.Text
		Controller:Describe()
	end
	self.Selected = Index
end

function Controller:Send()
	local Cmd = self.Registry.Info[self.Command]
	if not Cmd then
		print("Invalid command.")
		return
	end

	local Words = Main.Entry.Text:split(" ")

	local HashParameters = {}
	for _, Parameter in pairs(Cmd.Parameters) do
		if not Parameter.Optional then
			table.insert(HashParameters, Parameter)
		end
	end
	--> Check if the are enough non optional parameters.
	if #Words - 1 < #HashParameters then
		print("Not enough params")
		return
	end

	for Index, Word in pairs(Words) do
		-- Check if the parameters that ARE there are invalid.
		if Index - 1 ~= 0 then
			local Parameter = Cmd.Parameters[Index - 1]
			if not Parameter or not Parameter.List then
				continue
			end

			local List = Make_Set_From_Array(Lists[Parameter.List]())
			if Parameter.Alternate then
				local Alternate = Make_Set_From_Array(Parameter.Alternate)
				if Alternate[string.lower(Word)] then
					break
				end
			end

			if not List[string.lower(Word)] then
				print("Invalid parameter")
				return
			end
		end
	end

	Network.Send("Command", Main.Entry.Text)

	Main.Entry:CaptureFocus()
	Main.Entry.Text = ""
	Main.Entry.CursorPosition = 1
end

function Controller:Hook(Input, GameProcessedEvent)
	if GuiService.MenuIsOpen or (GameProcessedEvent and not Ordr.Enabled) then
		return
	end

	if self.Registry and self.Registry.ActivationKeys and self.Registry.ActivationKeys[Input.KeyCode] then
		self:Enable(not Ordr.Enabled)
	end

	if not Ordr.Enabled then
		return
	end

	if Input.KeyCode == Enum.KeyCode.Return or Input.KeyCode == Enum.KeyCode.KeypadEnter then
		self:Send()
	end

	if Input.KeyCode == Enum.KeyCode.Up then
		self:Select(self.Selected - 1)
	elseif Input.KeyCode == Enum.KeyCode.Down then
		self:Select(self.Selected + 1)
	end

	if Input.KeyCode == Enum.KeyCode.Tab then
		self:Autofill()
	end
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	Controller:Hook(Input, GameProcessedEvent)
end)

local PreviousWordCount = 0

Main.Entry:GetPropertyChangedSignal("Text"):Connect(function()
	--/ Eat
	if Main.Entry.Text:match("\t") then
		Main.Entry.Text = Main.Entry.Text:gsub("\t", "")
		return
	end

	Controller:Suggest()

	local Words = Main.Entry.Text:split(" ")
	local WordCount = #Words

	if WordCount ~= PreviousWordCount then
		Controller:Describe()
		PreviousWordCount = WordCount
	end

	if Main.Entry.Text == "" then
		Main.Tooltip.Text = ""
	end
end)

return Controller
