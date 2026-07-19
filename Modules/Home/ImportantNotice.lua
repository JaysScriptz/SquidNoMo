local ImportantNotice = {}

function ImportantNotice:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(1,0,0,245)
	)

	Card.LayoutOrder = 99

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,18)
	Padding.PaddingBottom = UDim.new(0,18)
	Padding.PaddingLeft = UDim.new(0,20)
	Padding.PaddingRight = UDim.new(0,20)
	Padding.Parent = Card

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,10)
	Layout.Parent = Card

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,0,0,24)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.FontBlack
	Title.Text = "⚠ Important Notice"
	Title.TextSize = 20
	Title.TextColor3 = Theme.Warning
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Body = Instance.new("TextLabel")
	Body.Size = UDim2.new(1,0,0,135)
	Body.BackgroundTransparency = 1
	Body.Font = Theme.Font
	Body.TextWrapped = true
	Body.TextYAlignment = Enum.TextYAlignment.Top
	Body.TextXAlignment = Enum.TextXAlignment.Left
	Body.TextSize = 14
	Body.TextColor3 = Theme.Text
	Body.Text =
[[• SquidNoMo is provided for educational and research purposes.

• Using third-party software may violate a game's Terms of Service.

• No feature can guarantee protection from detection or enforcement actions.

• You are responsible for how you use this software.

• By continuing, you acknowledge all associated risks.]]
	Body.Parent = Card

	local Risk = Instance.new("TextLabel")
	Risk.Size = UDim2.new(1,0,0,20)
	Risk.BackgroundTransparency = 1
	Risk.Font = Theme.FontBold
	Risk.Text = "Current Risk: Unknown"
	Risk.TextSize = 15
	Risk.TextColor3 = Theme.Accent
	Risk.TextXAlignment = Enum.TextXAlignment.Left
	Risk.Parent = Card

	return Card

end

return ImportantNotice
