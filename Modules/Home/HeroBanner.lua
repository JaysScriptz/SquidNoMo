local HeroBanner = {}

function HeroBanner:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(1,0,0,170)
	)

	Card.LayoutOrder = 1

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,20)
	Padding.PaddingBottom = UDim.new(0,20)
	Padding.PaddingLeft = UDim.new(0,24)
	Padding.PaddingRight = UDim.new(0,24)
	Padding.Parent = Card

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1,0,0,40)
	Title.Font = Theme.FontBlack
	Title.Text = "SquidNoMo"
	Title.TextSize = 34
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Subtitle = Instance.new("TextLabel")
	Subtitle.BackgroundTransparency = 1
	Subtitle.Position = UDim2.fromOffset(0,48)
	Subtitle.Size = UDim2.new(1,0,0,22)
	Subtitle.Font = Theme.Font
	Subtitle.Text = "Modern • Responsive • Modular"
	Subtitle.TextSize = 16
	Subtitle.TextColor3 = Theme.SubText
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = Card

	local Description = Instance.new("TextLabel")
	Description.BackgroundTransparency = 1
	Description.Position = UDim2.fromOffset(0,82)
	Description.Size = UDim2.new(1,-220,0,54)
	Description.Font = Theme.Font
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.TextSize = 15
	Description.TextColor3 = Theme.Text
	Description.Text = "A complete modular utility designed with a responsive interface for desktop and mobile devices."
	Description.Parent = Card

	local Version = Instance.new("TextLabel")
	Version.AnchorPoint = Vector2.new(1,1)
	Version.Position = UDim2.new(1,0,1,0)
	Version.Size = UDim2.fromOffset(180,22)
	Version.BackgroundTransparency = 1
	Version.Font = Theme.FontBold
	Version.Text = "Beta 5.0"
	Version.TextSize = 15
	Version.TextColor3 = Theme.Accent
	Version.TextXAlignment = Enum.TextXAlignment.Right
	Version.Parent = Card

	return Card

end

return HeroBanner
