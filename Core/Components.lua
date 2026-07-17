--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Components.lua
--//========================================================--

local TweenService = game:GetService("TweenService")

local Components = {}

----------------------------------------------------------
-- Card
----------------------------------------------------------

function Components:CreateCard(Parent, Theme, Size)

	local Card = Instance.new("Frame")

	Card.Size = Size

	Card.BackgroundColor3 = Theme.Card

	Card.BorderSizePixel = 0

	Card.Parent = Parent

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,16)

	Corner.Parent = Card

	local Stroke = Instance.new("UIStroke")

	Stroke.Color = Theme.BorderDark

	Stroke.Thickness = 1

	Stroke.Parent = Card

	return Card

end

----------------------------------------------------------
-- Section Title
----------------------------------------------------------

function Components:CreateTitle(Parent, Theme, Text)

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1

	Label.Position = UDim2.fromOffset(18,16)

	Label.Size = UDim2.new(1,-36,0,24)

	Label.Font = Theme.FontBlack

	Label.Text = Text

	Label.TextSize = 18

	Label.TextColor3 = Theme.Text

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Parent

	return Label

end

----------------------------------------------------------
-- Button
----------------------------------------------------------

function Components:CreateButton(Parent, Theme, Text)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,0,40)

	Button.BackgroundColor3 = Theme.Accent

	Button.BorderSizePixel = 0

	Button.Font = Theme.FontBold

	Button.Text = Text

	Button.TextSize = 15

	Button.TextColor3 = Color3.new(1,1,1)

	Button.AutoButtonColor = false

	Button.Parent = Parent

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,10)

	Corner.Parent = Button

	Button.MouseEnter:Connect(function()

		TweenService:Create(

			Button,

			TweenInfo.new(.15),

			{

				BackgroundTransparency = .08

			}

		):Play()

	end)

	Button.MouseLeave:Connect(function()

		TweenService:Create(

			Button,

			TweenInfo.new(.15),

			{

				BackgroundTransparency = 0

			}

		):Play()

	end)

	return Button

end

----------------------------------------------------------
-- Toggle
----------------------------------------------------------

function Components:CreateToggle(Parent, Theme, Text)

	local Toggle = {}

	Toggle.Enabled = false

	------------------------------------------------------
	-- Holder
	------------------------------------------------------

	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,42)

	Holder.BackgroundTransparency = 1

	Holder.Parent = Parent

	------------------------------------------------------
	-- Label
	------------------------------------------------------

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1

	Label.Position = UDim2.fromOffset(0,0)

	Label.Size = UDim2.new(1,-70,1,0)

	Label.Font = Theme.Font

	Label.Text = Text

	Label.TextSize = 15

	Label.TextColor3 = Theme.Text

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Holder

	------------------------------------------------------
	-- Switch Background
	------------------------------------------------------

	local Switch = Instance.new("Frame")

	Switch.Size = UDim2.fromOffset(52,28)

	Switch.AnchorPoint = Vector2.new(1,.5)

	Switch.Position = UDim2.new(1,0,.5,0)

	Switch.BackgroundColor3 = Theme.Card

	Switch.BorderSizePixel = 0

	Switch.Parent = Holder

	local SwitchCorner = Instance.new("UICorner")

	SwitchCorner.CornerRadius = UDim.new(1,0)

	SwitchCorner.Parent = Switch

	------------------------------------------------------
	-- Knob
	------------------------------------------------------

	local Knob = Instance.new("Frame")

	Knob.Size = UDim2.fromOffset(22,22)

	Knob.Position = UDim2.fromOffset(3,3)

	Knob.BackgroundColor3 = Theme.Text

	Knob.BorderSizePixel = 0

	Knob.Parent = Switch

	local KnobCorner = Instance.new("UICorner")

	KnobCorner.CornerRadius = UDim.new(1,0)

	KnobCorner.Parent = Knob

	------------------------------------------------------
	-- Animation
	------------------------------------------------------

	local function Refresh()

		if Toggle.Enabled then

			TweenService:Create(

				Switch,

				TweenInfo.new(.15),

				{

					BackgroundColor3 = Theme.Accent

				}

			):Play()

			TweenService:Create(

				Knob,

				TweenInfo.new(.15),

				{

					Position = UDim2.fromOffset(27,3)

				}

			):Play()

		else

			TweenService:Create(

				Switch,

				TweenInfo.new(.15),

				{

					BackgroundColor3 = Theme.Card

				}

			):Play()

			TweenService:Create(

				Knob,

				TweenInfo.new(.15),

				{

					Position = UDim2.fromOffset(3,3)

				}

			):Play()

		end

	end

	------------------------------------------------------
	-- Click
	------------------------------------------------------

	local Button = Instance.new("TextButton")

	Button.BackgroundTransparency = 1

	Button.Size = UDim2.fromScale(1,1)

	Button.Text = ""

	Button.Parent = Holder

	Button.MouseButton1Click:Connect(function()

		Toggle.Enabled = not Toggle.Enabled

		Refresh()

		if Toggle.Callback then
			Toggle.Callback(Toggle.Enabled)
		end

	end)

	------------------------------------------------------
	-- API
	------------------------------------------------------

	function Toggle:Set(Value)

		Toggle.Enabled = Value

		Refresh()

	end

	function Toggle:Get()

		return Toggle.Enabled

	end

	function Toggle:OnChanged(Function)

		Toggle.Callback = Function

	end

	Refresh()

	return Holder, Toggle

		end

		----------------------------------------------------------
-- Slider
----------------------------------------------------------

function Components:CreateSlider(Parent, Theme, Title, Min, Max, Default)

	local Slider = {}

	Slider.Value = Default or Min

	------------------------------------------------------
	-- Holder
	------------------------------------------------------

	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,62)

	Holder.BackgroundTransparency = 1

	Holder.Parent = Parent

	------------------------------------------------------
	-- Title
	------------------------------------------------------

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1

	Label.Size = UDim2.new(1,-60,0,20)

	Label.Font = Theme.Font

	Label.Text = Title

	Label.TextSize = 15

	Label.TextColor3 = Theme.Text

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Holder

	------------------------------------------------------
	-- Value Label
	------------------------------------------------------

	local ValueLabel = Instance.new("TextLabel")

	ValueLabel.AnchorPoint = Vector2.new(1,0)

	ValueLabel.Position = UDim2.new(1,0,0,0)

	ValueLabel.Size = UDim2.new(0,50,0,20)

	ValueLabel.BackgroundTransparency = 1

	ValueLabel.Font = Theme.FontBold

	ValueLabel.Text = tostring(Slider.Value)

	ValueLabel.TextSize = 15

	ValueLabel.TextColor3 = Theme.Accent

	ValueLabel.Parent = Holder

	------------------------------------------------------
	-- Track
	------------------------------------------------------

	local Track = Instance.new("Frame")

	Track.Position = UDim2.new(0,0,0,34)

	Track.Size = UDim2.new(1,0,0,6)

	Track.BackgroundColor3 = Theme.Card

	Track.BorderSizePixel = 0

	Track.Parent = Holder

	local TrackCorner = Instance.new("UICorner")

	TrackCorner.CornerRadius = UDim.new(1,0)

	TrackCorner.Parent = Track

	------------------------------------------------------
	-- Fill
	------------------------------------------------------

	local Fill = Instance.new("Frame")

	Fill.Size = UDim2.new(
		(Slider.Value-Min)/(Max-Min),
		0,
		1,
		0
	)

	Fill.BackgroundColor3 = Theme.Accent

	Fill.BorderSizePixel = 0

	Fill.Parent = Track

	local FillCorner = Instance.new("UICorner")

	FillCorner.CornerRadius = UDim.new(1,0)

	FillCorner.Parent = Fill

	------------------------------------------------------
	-- Dragging
	------------------------------------------------------

	local Dragging = false

	local function Update(X)

		local Percent =
			math.clamp(

				(X-Track.AbsolutePosition.X) /
				Track.AbsoluteSize.X,

				0,

				1

			)

		Slider.Value =
			math.floor(
				Min + ((Max-Min)*Percent)
			)

		ValueLabel.Text =
			tostring(Slider.Value)

		Fill.Size =
			UDim2.new(Percent,0,1,0)

		if Slider.Callback then
			Slider.Callback(Slider.Value)
		end

	end

	Track.InputBegan:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = true

			Update(Input.Position.X)

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if Dragging then

			if Input.UserInputType ==
				Enum.UserInputType.MouseMovement
				or
				Input.UserInputType ==
				Enum.UserInputType.Touch then

				Update(Input.Position.X)

			end

		end

	end)

	UserInputService.InputEnded:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or
			Input.UserInputType ==
			Enum.UserInputType.Touch then

			Dragging = false

		end

	end)

	------------------------------------------------------
	-- API
	------------------------------------------------------

	function Slider:Get()

		return Slider.Value

	end

	function Slider:Set(Value)

		Slider.Value = Value

	end

	function Slider:OnChanged(Function)

		Slider.Callback = Function

	end

	return Holder,Slider

				end

				----------------------------------------------------------
-- Section
----------------------------------------------------------

function Components:CreateSection(Parent, Theme, Title)

	local Section = Instance.new("Frame")

	Section.BackgroundTransparency = 1

	Section.AutomaticSize = Enum.AutomaticSize.Y

	Section.Size = UDim2.new(1,0,0,0)

	Section.Parent = Parent

	local Layout = Instance.new("UIListLayout")

	Layout.Padding = UDim.new(0,10)

	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	Layout.Parent = Section

	local Header = Instance.new("TextLabel")

	Header.BackgroundTransparency = 1

	Header.Size = UDim2.new(1,0,0,26)

	Header.Font = Theme.FontBlack

	Header.Text = Title

	Header.TextSize = 19

	Header.TextColor3 = Theme.Text

	Header.TextXAlignment = Enum.TextXAlignment.Left

	Header.Parent = Section

	local Divider = Instance.new("Frame")

	Divider.Size = UDim2.new(1,0,0,1)

	Divider.BackgroundColor3 = Theme.BorderDark

	Divider.BorderSizePixel = 0

	Divider.Parent = Section

	local Content = Instance.new("Frame")

	Content.BackgroundTransparency = 1

	Content.AutomaticSize = Enum.AutomaticSize.Y

	Content.Size = UDim2.new(1,0,0,0)

	Content.Parent = Section

	local ContentLayout = Instance.new("UIListLayout")

	ContentLayout.Padding = UDim.new(0,8)

	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

	ContentLayout.Parent = Content

	return Content

				end

				
