local Supporters = {}

function Supporters:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(.34,-8,0,210)
	)

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0,18)
	Padding.PaddingBottom = UDim.new(0,18)
	Padding.PaddingLeft = UDim.new(0,18)
	Padding.PaddingRight = UDim.new(0,18)
	Padding.Parent = Card

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,8)
	Layout.Parent = Card

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,0,0,24)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.FontBlack
	Title.Text = "Supporters"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local Empty = Instance.new("TextLabel")
	Empty.Size = UDim2.new(1,0,0,22)
	Empty.BackgroundTransparency = 1
	Empty.Font = Theme.FontBold
	Empty.Text = "No supporters yet"
	Empty.TextSize = 15
	Empty.TextColor3 = Theme.Accent
	Empty.TextXAlignment = Enum.TextXAlignment.Left
	Empty.Parent = Card

	local List = Instance.new("Frame")
	List.Size = UDim2.new(1,0,0,100)
	List.BackgroundTransparency = 1
	List.Parent = Card

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Padding = UDim.new(0,6)
	ListLayout.Parent = List

	function Card:AddSupporter(Name)

		if Empty then
			Empty:Destroy()
			Empty = nil
		end

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1,0,0,20)
		Label.BackgroundTransparency = 1
		Label.Font = Theme.Font
		Label.Text = "❤️  "..Name
		Label.TextSize = 14
		Label.TextColor3 = Theme.Text
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = List

	end

	return Card

end

return Supporters
