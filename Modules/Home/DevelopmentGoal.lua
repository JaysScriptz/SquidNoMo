local DevelopmentGoal = {}

function DevelopmentGoal:Create(Parent, App)

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
	Title.Text = "Development Goal"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Goal = Instance.new("TextLabel")
	Goal.Size = UDim2.new(1,0,0,18)
	Goal.BackgroundTransparency = 1
	Goal.Font = Theme.FontBold
	Goal.Text = "$250 Goal"
	Goal.TextSize = 15
	Goal.TextColor3 = Theme.Accent
	Goal.TextXAlignment = Enum.TextXAlignment.Left
	Goal.Parent = Card

	local Bar = Instance.new("Frame")
	Bar.Size = UDim2.new(1,0,0,12)
	Bar.BackgroundColor3 = Theme.Card
	Bar.BorderSizePixel = 0
	Bar.Parent = Card

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1,0)
	Corner.Parent = Bar

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new(.28,0,1,0)
	Fill.BackgroundColor3 = Theme.Accent
	Fill.BorderSizePixel = 0
	Fill.Parent = Bar

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1,0)
	FillCorner.Parent = Fill

	local Progress = Instance.new("TextLabel")
	Progress.Size = UDim2.new(1,0,0,18)
	Progress.BackgroundTransparency = 1
	Progress.Font = Theme.Font
	Progress.Text = "$70 / $250 (28%)"
	Progress.TextSize = 14
	Progress.TextColor3 = Theme.SubText
	Progress.TextXAlignment = Enum.TextXAlignment.Left
	Progress.Parent = Card

	function Card:SetGoal(Current, Target)

		local Percent = math.clamp(Current / Target,0,1)

		Fill.Size = UDim2.new(Percent,0,1,0)

		Progress.Text =
			string.format(
				"$%d / $%d (%d%%)",
				Current,
				Target,
				math.floor(Percent*100)
			)

	end

	return Card

end

return DevelopmentGoal
