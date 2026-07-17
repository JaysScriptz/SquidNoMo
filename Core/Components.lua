--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Components.lua
--//========================================================--

local Components = {}

----------------------------------------------------------
-- Card
----------------------------------------------------------

function Components:CreateCard(Parent, Theme, Size, Position)

	local Card = Instance.new("Frame")

	Card.Size = Size
	Card.Position = Position
	Card.BackgroundColor3 = Theme.Card
	Card.BorderSizePixel = 0
	Card.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Theme.CardRadius)
	Corner.Parent = Card

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.BorderDark
	Stroke.Thickness = 1
	Stroke.Parent = Card

	return Card

end

----------------------------------------------------------
-- Title
----------------------------------------------------------

function Components:CreateTitle(Parent, Theme, Text)

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1,-40,0,24)
	Label.Position = UDim2.fromOffset(20,16)

	Label.Font = Theme.FontBold

	Label.Text = Text

	Label.TextColor3 = Theme.Text

	Label.TextSize = 20

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Parent

	return Label

end

----------------------------------------------------------
-- Subtitle
----------------------------------------------------------

function Components:CreateSubtitle(Parent, Theme, Text)

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1,-40,0,18)
	Label.Position = UDim2.fromOffset(20,42)

	Label.Font = Theme.Font

	Label.Text = Text

	Label.TextColor3 = Theme.SubText

	Label.TextSize = 13

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Parent

	return Label

end

----------------------------------------------------------
-- Button
----------------------------------------------------------

function Components:CreateButton(Parent, Theme, Text)

	local Button = Instance.new("TextButton")

	Button.BackgroundColor3 = Theme.Accent

	Button.AutoButtonColor = false

	Button.BorderSizePixel = 0

	Button.Font = Theme.FontBold

	Button.Text = Text

	Button.TextSize = 14

	Button.TextColor3 = Color3.fromRGB(15,15,15)

	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Theme.ButtonRadius)
	Corner.Parent = Button

	return Button

end

----------------------------------------------------------
-- Toggle
----------------------------------------------------------

function Components:CreateToggle(Parent, Theme, Text)

	local Holder = Instance.new("Frame")

	Holder.BackgroundTransparency = 1

	Holder.Size = UDim2.new(1,0,0,36)

	Holder.Parent = Parent

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1

	Label.Size = UDim2.new(.7,0,1,0)

	Label.Font = Theme.FontMedium

	Label.Text = Text

	Label.TextColor3 = Theme.Text

	Label.TextSize = 14

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Holder

	local Toggle = Instance.new("TextButton")

	Toggle.AnchorPoint = Vector2.new(1,.5)

	Toggle.Position = UDim2.new(1,-5,.5,0)

	Toggle.Size = UDim2.fromOffset(50,24)

	Toggle.BackgroundColor3 = Theme.BorderDark

	Toggle.Text = ""

	Toggle.AutoButtonColor = false

	Toggle.Parent = Holder

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1,0)
	Corner.Parent = Toggle

	local Knob = Instance.new("Frame")

	Knob.Size = UDim2.fromOffset(18,18)

	Knob.Position = UDim2.fromOffset(3,3)

	Knob.BackgroundColor3 = Color3.new(1,1,1)

	Knob.Parent = Toggle

	local KC = Instance.new("UICorner")
	KC.CornerRadius = UDim.new(1,0)
	KC.Parent = Knob

	local Enabled = false

	Toggle.MouseButton1Click:Connect(function()

		Enabled = not Enabled

		if Enabled then

			Toggle.BackgroundColor3 = Theme.Accent

			Knob.Position = UDim2.fromOffset(29,3)

		else

			Toggle.BackgroundColor3 = Theme.BorderDark

			Knob.Position = UDim2.fromOffset(3,3)

		end

	end)

	return Holder, Toggle

end

----------------------------------------------------------
-- Progress Bar
----------------------------------------------------------

function Components:CreateProgressBar(Parent, Theme)

	local Bar = Instance.new("Frame")

	Bar.BackgroundColor3 = Theme.BorderDark

	Bar.BorderSizePixel = 0

	Bar.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1,0)
	Corner.Parent = Bar

	local Fill = Instance.new("Frame")

	Fill.Size = UDim2.new(0,0,1,0)

	Fill.BackgroundColor3 = Theme.Accent

	Fill.BorderSizePixel = 0

	Fill.Parent = Bar

	local FC = Instance.new("UICorner")
	FC.CornerRadius = UDim.new(1,0)
	FC.Parent = Fill

	return Bar, Fill

end

----------------------------------------------------------
-- Info Row
----------------------------------------------------------

function Components:CreateInfoRow(Parent, Theme, LeftText, RightText)

	local Row = Instance.new("Frame")

	Row.BackgroundTransparency = 1

	Row.Size = UDim2.new(1,0,0,20)

	Row.Parent = Parent

	local Left = Instance.new("TextLabel")

	Left.BackgroundTransparency = 1

	Left.Size = UDim2.new(.55,0,1,0)

	Left.Font = Theme.Font

	Left.Text = LeftText

	Left.TextColor3 = Theme.Text

	Left.TextSize = 14

	Left.TextXAlignment = Enum.TextXAlignment.Left

	Left.Parent = Row

	local Right = Instance.new("TextLabel")

	Right.BackgroundTransparency = 1

	Right.Position = UDim2.new(.55,0,0,0)

	Right.Size = UDim2.new(.45,0,1,0)

	Right.Font = Theme.FontBold

	Right.Text = RightText

	Right.TextColor3 = Theme.Accent

	Right.TextSize = 14

	Right.TextXAlignment = Enum.TextXAlignment.Right

	Right.Parent = Row

	return Row, Left, Right

end

----------------------------------------------------------
-- Spacer
----------------------------------------------------------

function Components:CreateSpacer(Parent, Height)

	local Space = Instance.new("Frame")

	Space.BackgroundTransparency = 1

	Space.Size = UDim2.new(1,0,0,Height)

	Space.Parent = Parent

	return Space

end

----------------------------------------------------------
-- Divider
----------------------------------------------------------

function Components:CreateDivider(Parent)

	local Line = Instance.new("Frame")

	Line.Size = UDim2.new(1,0,0,1)

	Line.BackgroundColor3 = Color3.fromRGB(50,50,50)

	Line.BorderSizePixel = 0

	Line.Parent = Parent

	return Line

end

return Components
