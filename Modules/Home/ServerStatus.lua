local ServerStatus = {}

function ServerStatus:Create(Parent, App)

	local Theme = App.Theme
	local Components = App.Components
	local Utilities = App.Utilities

	local Card = Components:CreateCard(
		Parent,
		UDim2.new(.33,-8,0,240)
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
	Title.Text = "Server Status"
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Card

	local function CreateRow(Name, Value)

		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1,0,0,22)
		Row.BackgroundTransparency = 1
		Row.Parent = Card

		local Left = Instance.new("TextLabel")
		Left.Size = UDim2.new(.55,0,1,0)
		Left.BackgroundTransparency = 1
		Left.Font = Theme.Font
		Left.Text = Name
		Left.TextSize = 15
		Left.TextColor3 = Theme.SubText
		Left.TextXAlignment = Enum.TextXAlignment.Left
		Left.Parent = Row

		local Right = Instance.new("TextLabel")
		Right.AnchorPoint = Vector2.new(1,0)
		Right.Position = UDim2.new(1,0,0,0)
		Right.Size = UDim2.new(.45,0,1,0)
		Right.BackgroundTransparency = 1
		Right.Font = Theme.FontBold
		Right.Text = tostring(Value)
		Right.TextSize = 15
		Right.TextColor3 = Theme.Accent
		Right.TextXAlignment = Enum.TextXAlignment.Right
		Right.Parent = Row

		return Right

	end

	local FPS = CreateRow("FPS", Utilities:GetFPS())
	local Ping = CreateRow("Ping", Utilities:GetPing())
	local Players = CreateRow("Players", Utilities:GetPlayerCount())
	local Age = CreateRow("Server Age", Utilities:GetServerAge())

	task.spawn(function()

		while Card.Parent do

			task.wait(1)

			FPS.Text = tostring(Utilities:GetFPS())
			Ping.Text = tostring(Utilities:GetPing())
			Players.Text = tostring(Utilities:GetPlayerCount())
			Age.Text = tostring(Utilities:GetServerAge())

		end

	end)

	return Card

end

return ServerStatus
