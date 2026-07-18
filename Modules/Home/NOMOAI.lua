local NOMOAI = {}

function NOMOAI:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(.34,-8,0,240)
	)

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,18)
	Padding.PaddingBottom = UDim.new(0,18)
	Padding.PaddingLeft = UDim.new(0,18)
	Padding.PaddingRight = UDim.new(0,18)
	Padding.Parent = Card

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,10)
	Layout.Parent = Card

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,0,0,26)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.FontBlack
	Title.Text = "NOMO AI"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Status = Instance.new("TextLabel")
	Status.Size = UDim2.new(1,0,0,20)
	Status.BackgroundTransparency = 1
	Status.Font = Theme.FontBold
	Status.Text = "● Online"
	Status.TextSize = 15
	Status.TextColor3 = Color3.fromRGB(0,220,120)
	Status.TextXAlignment = Enum.TextXAlignment.Left
	Status.Parent = Card

	local Output = Instance.new("TextLabel")
	Output.Size = UDim2.new(1,0,0,110)
	Output.BackgroundTransparency = 1
	Output.Font = Theme.Font
	Output.TextWrapped = true
	Output.TextXAlignment = Enum.TextXAlignment.Left
	Output.TextYAlignment = Enum.TextYAlignment.Top
	Output.TextSize = 15
	Output.TextColor3 = Theme.Text
	Output.Text =
		"Welcome back.\n\n" ..
		"The dashboard is online.\n" ..
		"All supported modules are ready.\n\n" ..
		"Select a category from the sidebar to begin."
	Output.Parent = Card

	local Hint = Instance.new("TextLabel")
	Hint.Size = UDim2.new(1,0,0,20)
	Hint.BackgroundTransparency = 1
	Hint.Font = Theme.Font
	Hint.Text = "Status updates will appear here."
	Hint.TextSize = 13
	Hint.TextColor3 = Theme.SubText
	Hint.TextXAlignment = Enum.TextXAlignment.Left
	Hint.Parent = Card

	function Card:SetMessage(Message)

		Output.Text = Message

	end

	return Card

end

return NOMOAI
