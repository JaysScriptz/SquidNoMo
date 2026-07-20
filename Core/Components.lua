--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Components.lua
--//========================================================--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Components = {}

Components.Theme = nil

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Components:Initialize(Theme)
	assert(Theme, "[Components] Theme is required")
	self.Theme = Theme
end

local function IsTheme(Value)
	return type(Value) == "table"
		and Value.Card ~= nil
		and Value.Text ~= nil
end

----------------------------------------------------------
-- Card
----------------------------------------------------------

function Components:CreateCard(Parent, ThemeOrSize, MaybeSize)

	local Theme = IsTheme(ThemeOrSize) and ThemeOrSize or self.Theme
	local Size = MaybeSize or ThemeOrSize

	assert(Theme, "[Components] Components:Initialize(theme) was not called")
	assert(Size, "[Components] CreateCard requires a size")

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
-- Section
----------------------------------------------------------

function Components:CreateSection(Parent, ThemeOrTitle, MaybeTitle)

	local Theme = IsTheme(ThemeOrTitle) and ThemeOrTitle or self.Theme
	local Title = MaybeTitle or ThemeOrTitle

	local Section = Instance.new("Frame")
	Section.BackgroundTransparency = 1
	Section.Size = UDim2.new(1,0,0,0)
	Section.AutomaticSize = Enum.AutomaticSize.Y
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
	Content.Size = UDim2.new(1,0,0,0)
	Content.AutomaticSize = Enum.AutomaticSize.Y
	Content.Parent = Section

	local ContentLayout = Instance.new("UIListLayout")
	ContentLayout.Padding = UDim.new(0,8)
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentLayout.Parent = Content

	return Content
end

----------------------------------------------------------
-- Sidebar Button
----------------------------------------------------------

function Components:SidebarButton(Parent, Name, Icon)

	local Theme = self.Theme

	local Button = Instance.new("TextButton")
	Button.Name = Name
	Button.Size = UDim2.new(1,0,0,42)
	Button.BackgroundColor3 = Theme.Card
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false
	Button.Text = ""
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = Button

	local IconLabel = Instance.new("TextLabel")
	IconLabel.BackgroundTransparency = 1
	IconLabel.Position = UDim2.fromOffset(14,0)
	IconLabel.Size = UDim2.fromOffset(24,42)
	IconLabel.Font = Theme.FontBold
	IconLabel.Text = Icon
	IconLabel.TextSize = 18
	IconLabel.TextColor3 = Theme.Text
	IconLabel.Parent = Button

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(46,0)
	Label.Size = UDim2.new(1,-46,1,0)
	Label.Font = Theme.Font
	Label.Text = Name
	Label.TextSize = 15
	Label.TextColor3 = Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	function Button:SetSelected(State)

		TweenService:Create(
			Button,
			TweenInfo.new(.15),
			{
				BackgroundColor3 =
					State and Theme.Accent or Theme.Card
			}
		):Play()

	end

	function Button:SetCompact(State)
		Label.Visible = not State
		if State then
			IconLabel.AnchorPoint = Vector2.new(.5,0)
			IconLabel.Position = UDim2.new(.5,0,0,0)
		else
			IconLabel.AnchorPoint = Vector2.new(0,0)
			IconLabel.Position = UDim2.fromOffset(14,0)
		end
	end

	return Button
end

----------------------------------------------------------
-- Title
----------------------------------------------------------

function Components:CreateTitle(Parent, ThemeOrText, MaybeText)

	local Theme = IsTheme(ThemeOrText) and ThemeOrText or self.Theme
	local Text = MaybeText or ThemeOrText

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(20,14)
	Title.Size = UDim2.new(1,-40,0,28)
	Title.Font = Theme.FontBlack
	Title.Text = tostring(Text or "")
	Title.TextSize = 19
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Parent

	return Title
end

----------------------------------------------------------
-- Button
----------------------------------------------------------

function Components:CreateButton(Parent, ThemeOrText, MaybeText)

	local Theme = IsTheme(ThemeOrText) and ThemeOrText or self.Theme
	local Text = MaybeText or ThemeOrText

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,0,40)
	Button.BackgroundColor3 = Theme.Accent
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false
	Button.Font = Theme.FontBold
	Button.Text = Text
	Button.TextSize = 15
	Button.TextColor3 = Color3.new(1,1,1)
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

function Components:CreateToggle(Parent, ThemeOrText, MaybeText)

	local Theme = IsTheme(ThemeOrText) and ThemeOrText or self.Theme
	local Text = MaybeText or ThemeOrText

	local Toggle = {}
	Toggle.Enabled = false


	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,42)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Parent


	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1,-70,1,0)
	Label.Font = Theme.Font
	Label.Text = Text
	Label.TextSize = 15
	Label.TextColor3 = Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder


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


	local Knob = Instance.new("Frame")

	Knob.Size = UDim2.fromOffset(22,22)
	Knob.Position = UDim2.fromOffset(3,3)
	Knob.BackgroundColor3 = Theme.Text
	Knob.BorderSizePixel = 0
	Knob.Parent = Switch


	local KnobCorner = Instance.new("UICorner")

	KnobCorner.CornerRadius = UDim.new(1,0)
	KnobCorner.Parent = Knob


	local function Refresh()

		TweenService:Create(
			Switch,
			TweenInfo.new(.15),
			{
				BackgroundColor3 =
					Toggle.Enabled
					and Theme.Accent
					or Theme.Card
			}
		):Play()


		TweenService:Create(
			Knob,
			TweenInfo.new(.15),
			{
				Position =
					Toggle.Enabled
					and UDim2.fromOffset(27,3)
					or UDim2.fromOffset(3,3)
			}
		):Play()

	end


	local Click = Instance.new("TextButton")

	Click.BackgroundTransparency = 1
	Click.Size = UDim2.fromScale(1,1)
	Click.Text = ""
	Click.Parent = Holder


	Click.MouseButton1Click:Connect(function()

		Toggle.Enabled = not Toggle.Enabled

		Refresh()

		if Toggle.Callback then
			Toggle.Callback(Toggle.Enabled)
		end

	end)


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

function Components:CreateSlider(
	Parent,
	ThemeOrTitle,
	TitleOrMin,
	MinOrMax,
	MaxOrDefault,
	MaybeDefault
)

	local Theme
	local Title
	local Min
	local Max
	local Default

	if IsTheme(ThemeOrTitle) then
		Theme = ThemeOrTitle
		Title = TitleOrMin
		Min = MinOrMax
		Max = MaxOrDefault
		Default = MaybeDefault
	else
		Theme = self.Theme
		Title = ThemeOrTitle
		Min = TitleOrMin
		Max = MinOrMax
		Default = MaxOrDefault
	end

	Min = tonumber(Min) or 0
	Max = tonumber(Max) or 100
	Default = tonumber(Default) or Min

	local Slider = {}

	Slider.Value = Default or Min


	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,62)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Parent


	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1,-60,0,20)
	Label.Font = Theme.Font
	Label.Text = Title
	Label.TextSize = 15
	Label.TextColor3 = Theme.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder


	local Value = Instance.new("TextLabel")

	Value.AnchorPoint = Vector2.new(1,0)
	Value.Position = UDim2.new(1,0,0,0)
	Value.Size = UDim2.new(0,50,0,20)
	Value.BackgroundTransparency = 1
	Value.Font = Theme.FontBold
	Value.Text = tostring(Slider.Value)
	Value.TextSize = 15
	Value.TextColor3 = Theme.Accent
	Value.Parent = Holder


	local Track = Instance.new("Frame")

	Track.Position = UDim2.new(0,0,0,34)
	Track.Size = UDim2.new(1,0,0,6)
	Track.BackgroundColor3 = Theme.Card
	Track.BorderSizePixel = 0
	Track.Parent = Holder


	local TrackCorner = Instance.new("UICorner")

	TrackCorner.CornerRadius = UDim.new(1,0)
	TrackCorner.Parent = Track


	local Fill = Instance.new("Frame")

	Fill.BackgroundColor3 = Theme.Accent
	Fill.BorderSizePixel = 0
	Fill.Parent = Track


	local FillCorner = Instance.new("UICorner")

	FillCorner.CornerRadius = UDim.new(1,0)
	FillCorner.Parent = Fill


	local function Refresh()

		local Percent =
			(Slider.Value-Min)/(Max-Min)

		Fill.Size =
			UDim2.new(
				math.clamp(Percent,0,1),
				0,
				1,
				0
			)

		Value.Text =
			tostring(Slider.Value)

	end


	local Dragging = false


	local function Update(X)

		local Percent =
			math.clamp(
				(X - Track.AbsolutePosition.X)
				/
				Track.AbsoluteSize.X,
				0,
				1
			)

		Slider.Value =
			math.floor(
				Min + ((Max-Min)*Percent)
			)

		Refresh()

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


	function Slider:Get()

		return Slider.Value

	end


	function Slider:Set(Value)

		Slider.Value = Value
		Refresh()

	end


	function Slider:OnChanged(Function)

		Slider.Callback = Function

	end


	Refresh()

	return Holder, Slider

end


----------------------------------------------------------
-- Dropdown
----------------------------------------------------------

function Components:CreateDropdown(
	Parent,
	ThemeOrTitle,
	TitleOrOptions,
	MaybeOptions
)

	local Theme
	local Title
	local Options

	if IsTheme(ThemeOrTitle) then
		Theme = ThemeOrTitle
		Title = TitleOrOptions
		Options = MaybeOptions
	else
		Theme = self.Theme
		Title = ThemeOrTitle
		Options = TitleOrOptions
	end

	local Dropdown = {}

	Dropdown.Value = nil


	local Holder = Instance.new("Frame")

	Holder.Size = UDim2.new(1,0,0,42)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Parent


	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(1,0,1,0)
	Button.BackgroundColor3 = Theme.Card
	Button.BorderSizePixel = 0
	Button.Font = Theme.Font
	Button.TextSize = 15
	Button.TextColor3 = Theme.Text
	Button.Text = Title
	Button.Parent = Holder


	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = Button


	function Dropdown:Set(Value)

		Dropdown.Value = Value

		Button.Text =
			Title.." : "..tostring(Value)

		if Dropdown.Callback then
			Dropdown.Callback(Value)
		end

	end


	function Dropdown:Get()

		return Dropdown.Value

	end


	function Dropdown:OnChanged(Function)

		Dropdown.Callback = Function

	end


	Button.MouseButton1Click:Connect(function()

		if Options and #Options > 0 then

			local Index = 1

			if Dropdown.Value then

				for i,v in ipairs(Options) do

					if v == Dropdown.Value then

						Index = i + 1
						break

					end

				end

			end


			if Index > #Options then
				Index = 1
			end


			Dropdown:Set(
				Options[Index]
			)

		end

	end)


	return Holder, Dropdown

						end


						----------------------------------------------------------
-- Textbox
----------------------------------------------------------

function Components:CreateTextbox(
	Parent,
	ThemeOrPlaceholder,
	MaybePlaceholder
)

	local Theme = IsTheme(ThemeOrPlaceholder) and ThemeOrPlaceholder or self.Theme
	local Placeholder = MaybePlaceholder or ThemeOrPlaceholder

	local Box = {}


	local TextBox = Instance.new("TextBox")

	TextBox.Size = UDim2.new(1,0,0,40)
	TextBox.BackgroundColor3 = Theme.Card
	TextBox.BorderSizePixel = 0
	TextBox.ClearTextOnFocus = false
	TextBox.PlaceholderText = Placeholder
	TextBox.Text = ""
	TextBox.Font = Theme.Font
	TextBox.TextSize = 15
	TextBox.TextColor3 = Theme.Text
	TextBox.PlaceholderColor3 = Theme.SubText
	TextBox.Parent = Parent


	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = TextBox


	TextBox.FocusLost:Connect(function()

		if Box.Callback then

			Box.Callback(
				TextBox.Text
			)

		end

	end)


	function Box:Get()

		return TextBox.Text

	end


	function Box:Set(Value)

		TextBox.Text =
			tostring(Value)

	end


	function Box:OnChanged(Function)

		Box.Callback = Function

	end


	return TextBox, Box

end


----------------------------------------------------------
-- Label
----------------------------------------------------------

function Components:CreateLabel(
	Parent,
	ThemeOrText,
	MaybeText
)

	local Theme = IsTheme(ThemeOrText) and ThemeOrText or self.Theme
	local Text = MaybeText or ThemeOrText

	local Label = Instance.new("TextLabel")

	Label.Size =
		UDim2.new(1,0,0,22)

	Label.BackgroundTransparency = 1

	Label.Font =
		Theme.Font

	Label.Text =
		Text

	Label.TextSize =
		15

	Label.TextColor3 =
		Theme.Text

	Label.TextXAlignment =
		Enum.TextXAlignment.Left

	Label.Parent =
		Parent

	return Label

end


----------------------------------------------------------
-- Spacer
----------------------------------------------------------

function Components:CreateSpacer(
	Parent,
	Height
)

	local Spacer = Instance.new("Frame")

	Spacer.BackgroundTransparency = 1

	Spacer.Size =
		UDim2.new(
			1,
			0,
			0,
			Height or 8
		)

	Spacer.Parent =
		Parent

	return Spacer

end


----------------------------------------------------------
-- Divider
----------------------------------------------------------

function Components:CreateDivider(
	Parent,
	MaybeTheme
)

	local Theme = IsTheme(MaybeTheme) and MaybeTheme or self.Theme

	local Divider = Instance.new("Frame")

	Divider.Size =
		UDim2.new(
			1,
			0,
			0,
			1
		)

	Divider.BackgroundColor3 =
		Theme.BorderDark

	Divider.BorderSizePixel =
		0

	Divider.Parent =
		Parent

	return Divider

end

----------------------------------------------------------
-- Horizontal Container
----------------------------------------------------------

function Components:CreateHorizontalContainer(Parent)

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1,0,0,250)
	Container.BackgroundTransparency = 1
	Container.Parent = Parent

	local Layout = Instance.new("UIListLayout")
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Top
	Layout.Padding = UDim.new(0,12)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Container

	local OriginalSizes = {}

	local function IsCard(Child)
		return Child:IsA("GuiObject")
	end

	local function Update()
		local Compact = Container.AbsoluteSize.X > 0
			and Container.AbsoluteSize.X < 720

		Layout.FillDirection = Compact
			and Enum.FillDirection.Vertical
			or Enum.FillDirection.Horizontal

		for _, Child in ipairs(Container:GetChildren()) do
			if IsCard(Child) then
				OriginalSizes[Child] = OriginalSizes[Child] or Child.Size
				local Base = OriginalSizes[Child]
				if Compact then
					local Height = Base.Y.Offset > 0 and Base.Y.Offset or math.max(Child.AbsoluteSize.Y, 180)
					Child.Size = UDim2.new(1,0,0,Height)
				else
					Child.Size = Base
				end
			end
		end

		task.defer(function()
			if Container.Parent then
				Container.Size = UDim2.new(1,0,0,math.max(Layout.AbsoluteContentSize.Y, 1))
			end
		end)
	end

	Container.ChildAdded:Connect(function(Child)
		if IsCard(Child) then
			OriginalSizes[Child] = Child.Size
		end
		task.defer(Update)
	end)

	Container.ChildRemoved:Connect(function(Child)
		OriginalSizes[Child] = nil
		task.defer(Update)
	end)

	Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(Update)
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if Container.Parent then
			Container.Size = UDim2.new(1,0,0,math.max(Layout.AbsoluteContentSize.Y, 1))
		end
	end)

	task.defer(Update)

	return Container

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Components
