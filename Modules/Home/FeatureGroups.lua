local FeatureGroups = {}

function FeatureGroups:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(.33,-8,0,285)
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
	Title.Text = "Feature Groups"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Features = {
		"👤 Players",
		"🛡 Guards",
		"🕵 Detective",
		"💰 Farming",
		"⭐ VIP",
		"🎮 Games",
		"⚙ Settings"
	}

	for _,Name in ipairs(Features) do

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1,0,0,20)
		Label.BackgroundTransparency = 1
		Label.Font = Theme.Font
		Label.Text = Name
		Label.TextSize = 15
		Label.TextColor3 = Theme.Text
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Card

	end

	return Card

end

return FeatureGroups
