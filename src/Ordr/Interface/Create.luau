local Players = game:GetService("Players")
local Player = Players.LocalPlayer

return function()
	local Ordr = Instance.new("ScreenGui")
	Ordr.Name = "Ordr"
	Ordr.ResetOnSpawn = false
	Ordr.AutoLocalize = false
	Ordr.Enabled = false

	local Mainframe = Instance.new("Frame")
	Mainframe.Name = "Mainframe"
	Mainframe.BackgroundColor3 = Color3.fromHex("#333535")
	Mainframe.BackgroundTransparency = 0.5
	Mainframe.Size = UDim2.fromScale(0.35, 0.2)
	Mainframe.AnchorPoint = Vector2.new(0, 0.5)
	Mainframe.Position = UDim2.new(0, 10, 0.5, 0)
	Mainframe.ClipsDescendants = false
	Mainframe.Parent = Ordr

	local Welcome = Instance.new("TextLabel")
	Welcome.Name = "Welcome"
	Welcome.BackgroundTransparency = 1
	Welcome.Size = UDim2.fromScale(0.5, 0.1) -- 50% width of Mainframe, 10% height
	Welcome.Font = Enum.Font.Code
	Welcome.Position = UDim2.fromScale(0.02, 0.02) -- top-left
	Welcome.TextSize = 14
	Welcome.TextColor3 = Color3.fromHex("#98e2ff")
	Welcome.TextStrokeTransparency = 0.5
	Welcome.TextXAlignment = Enum.TextXAlignment.Left
	Welcome.TextYAlignment = Enum.TextYAlignment.Top
	Welcome.Text = string.format("@user : %s", Player.Name)
	Welcome.Parent = Mainframe

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Name = "Output"
	Scroll.BackgroundColor3 = Color3.fromHex("#393a3a")
	Scroll.BackgroundTransparency = 1
	Scroll.Size = UDim2.fromScale(0.4, 1)
	Scroll.ClipsDescendants = true
	Scroll.ScrollBarThickness = 2
	Scroll.AnchorPoint = Vector2.new(1, 0)
	Scroll.Position = UDim2.fromScale(1, 0)
	Scroll.Parent = Mainframe

	local Entry = Instance.new("TextBox")
	Entry.Name = "Entry"
	Entry.ClearTextOnFocus = true
	Entry.Font = Enum.Font.Code
	Entry.TextSize = 14
	Entry.Text = ""
	Entry.TextColor3 = Color3.fromHex("#ffffff")
	Entry.PlaceholderText = "Type command..."
	Entry.BackgroundTransparency = 1
	Entry.ClipsDescendants = true
	Entry.TextXAlignment = Enum.TextXAlignment.Left
	Entry.TextYAlignment = Enum.TextYAlignment.Center
	Entry.RichText = true
	Entry.Size = UDim2.fromScale(0.55, 0.1)
	Entry.AnchorPoint = Vector2.new(0, 1)
	Entry.Position = UDim2.fromScale(0.02, 0.95)
	Entry.Parent = Mainframe

	local Suggestions = Instance.new("Frame")
	Suggestions.BackgroundColor3 = Color3.fromHex("#444448")
	Suggestions.Name = "Suggestions"
	Suggestions.Size = UDim2.fromScale(0.25, 0)
	Suggestions.BorderSizePixel = 0
	Suggestions.AnchorPoint = Vector2.new(0, 0)
	Suggestions.Position = UDim2.fromScale(0, 1)
	Suggestions.ClipsDescendants = true
	Suggestions.AutomaticSize = Enum.AutomaticSize.Y
	Suggestions.Parent = Mainframe

	local Layout = Instance.new("UIListLayout")
	Layout.Parent = Suggestions
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 2)

	local Tooltip = Instance.new("TextLabel")
	Tooltip.Font = Enum.Font.Code
	Tooltip.TextSize = 12 -- base size for the body
	Tooltip.RichText = true
	Tooltip.Size = UDim2.fromScale(0.25, 0.45) -- adjust width/height as needed
	Tooltip.BackgroundTransparency = 1
	Tooltip.AnchorPoint = Vector2.new(0, 0.6) -- middle-left of tooltip
	Tooltip.Position = UDim2.new(0, 9, 0.6, 0) -- 5 pixels offset from left, vertically centered
	Tooltip.TextXAlignment = Enum.TextXAlignment.Left
	Tooltip.TextYAlignment = Enum.TextYAlignment.Bottom
	Tooltip.Name = "Tooltip"
	Tooltip.TextColor3 = Color3.fromHex("#ffffff")
	Tooltip.Text = ""
	Tooltip.Parent = Mainframe

	return Ordr
end
