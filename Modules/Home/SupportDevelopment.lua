local SupportDevelopment = {}

function SupportDevelopment:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(.33,-8,0,190)
	)

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,18)
	Padding.PaddingBottom = UDim.new(0,18)
	Padding.PaddingLeft = UDim.new(0,18)
	Padding.PaddingRight = UDim.new(0,18)
	Padding.Parent = Card

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,12)
	Layout.Parent = Card

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,0,0,24)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.FontBlack
	Title.Text = "Support Development"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Description = Instance.new("TextLabel")
	Description.Size = UDim2.new(1,0,0,55)
	Description.BackgroundTransparency = 1
	Description.Font = Theme.Font
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.TextSize = 15
	Description.TextColor3 = Theme.Text
	Description.Text = "Support SquidNoMo to help fund future updates, maintenance and new features."
	Description.Parent = Card

	local Donate = Components:CreateButton(
		Card,
		"Support Project"
	)

	Donate.MouseButton1Click:Connect(function()

		print("Support Development Clicked")

	end)

	return Card

end

return SupportDevelopment
