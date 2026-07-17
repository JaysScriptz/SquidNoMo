--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Home.lua
--// Dashboard
--//========================================================--

local RunService = game:GetService("RunService")

local Home = {}

function Home:Create(Page, App)

	----------------------------------------------------------
	-- References
	----------------------------------------------------------

	local Theme = App.Theme
	local Components = App.Components
	local Utilities = App.Utilities
	local Notifications = App.Notifications

	----------------------------------------------------------
	-- Page Layout
	----------------------------------------------------------

	Page.BackgroundTransparency = 1

	local MainLayout = Instance.new("UIListLayout")

	MainLayout.FillDirection = Enum.FillDirection.Vertical
	MainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	MainLayout.Padding = UDim.new(0,18)

	MainLayout.Parent = Page

	----------------------------------------------------------
	-- Hero Banner
	----------------------------------------------------------

	local Banner = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,260),
		UDim2.new()

	)

	Banner.LayoutOrder = 1

	local BannerImage = Instance.new("ImageLabel")

	BannerImage.Name = "Banner"

	BannerImage.BackgroundTransparency = 1

	BannerImage.Size = UDim2.fromScale(1,1)

	BannerImage.Image = Theme.Assets.HeroImage

	BannerImage.ScaleType = Enum.ScaleType.Crop

	BannerImage.Parent = Banner

	local ImageCorner = Instance.new("UICorner")

	ImageCorner.CornerRadius = UDim.new(0,Theme.CardRadius)

	ImageCorner.Parent = BannerImage

	local Overlay = Instance.new("Frame")

	Overlay.Size = UDim2.fromScale(1,1)

	Overlay.BackgroundColor3 = Color3.new()

	Overlay.BackgroundTransparency = .45

	Overlay.Parent = Banner

	local OverlayCorner = Instance.new("UICorner")

	OverlayCorner.CornerRadius = UDim.new(0,Theme.CardRadius)

	OverlayCorner.Parent = Overlay

	local Title = Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position = UDim2.fromOffset(30,26)

	Title.Size = UDim2.new(.6,0,0,60)

	Title.Font = Theme.FontBlack

	Title.Text = "Welcome to\nSquidNoMo!"

	Title.TextSize = 34

	Title.TextColor3 = Theme.Text

	Title.TextXAlignment = Enum.TextXAlignment.Left

	Title.TextYAlignment = Enum.TextYAlignment.Top

	Title.Parent = Banner

	local Description = Instance.new("TextLabel")

	Description.BackgroundTransparency = 1

	Description.Position = UDim2.fromOffset(30,118)

	Description.Size = UDim2.new(.55,0,0,70)

	Description.Font = Theme.Font

	Description.TextWrapped = true

	Description.TextSize = 17

	Description.TextColor3 = Theme.SubText

	Description.TextXAlignment = Enum.TextXAlignment.Left

	Description.TextYAlignment = Enum.TextYAlignment.Top

	Description.Text =
		"SquidNoMo is an advanced all-in-one toolkit for Squid Game X featuring automation, utilities, farming tools, player controls, and intelligent dashboard monitoring."

	Description.Parent = Banner

	local Footer = Instance.new("TextLabel")

	Footer.BackgroundTransparency = 1

	Footer.Position = UDim2.fromOffset(30,218)

	Footer.Size = UDim2.new(.6,0,0,22)

	Footer.Font = Theme.FontBold

	Footer.Text = "Squid Game X  •  Beta 4.0"

	Footer.TextSize = 16

	Footer.TextColor3 = Theme.Accent

	Footer.TextXAlignment = Enum.TextXAlignment.Left

	Footer.Parent = Banner

	----------------------------------------------------------
	-- Dashboard Row
	----------------------------------------------------------

	local Row = Instance.new("Frame")

	Row.BackgroundTransparency = 1

	Row.Size = UDim2.new(1,0,0,650)

	Row.LayoutOrder = 2

	Row.Parent = Page

	local RowLayout = Instance.new("UIListLayout")

	RowLayout.FillDirection = Enum.FillDirection.Horizontal

	RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	RowLayout.Padding = UDim.new(0,18)

	RowLayout.Parent = Row

	----------------------------------------------------------
	-- Left Column
	----------------------------------------------------------

	local LeftColumn = Instance.new("Frame")

	LeftColumn.BackgroundTransparency = 1

	LeftColumn.Size = UDim2.new(.33,0,1,0)

	LeftColumn.Parent = Row

	local LeftLayout = Instance.new("UIListLayout")

	LeftLayout.Padding = UDim.new(0,18)

	LeftLayout.Parent = LeftColumn

	----------------------------------------------------------
	-- Middle Column
	----------------------------------------------------------

	local MiddleColumn = Instance.new("Frame")

	MiddleColumn.BackgroundTransparency = 1

	MiddleColumn.Size = UDim2.new(.34,0,1,0)

	MiddleColumn.Parent = Row

	local MiddleLayout = Instance.new("UIListLayout")

	MiddleLayout.Padding = UDim.new(0,18)

	MiddleLayout.Parent = MiddleColumn

	----------------------------------------------------------
	-- Right Column
	----------------------------------------------------------

	local RightColumn = Instance.new("Frame")

	RightColumn.BackgroundTransparency = 1

	RightColumn.Size = UDim2.new(.33,0,1,0)

	RightColumn.Parent = Row

	local RightLayout = Instance.new("UIListLayout")

	RightLayout.Padding = UDim.new(0,18)

	RightLayout.Parent = RightColumn

	----------------------------------------------------------
	-- Save References
	----------------------------------------------------------

	self.Page = Page

	self.LeftColumn = LeftColumn

	self.MiddleColumn = MiddleColumn

	self.RightColumn = RightColumn

		----------------------------------------------------------
	-- Feature Group Controls
	----------------------------------------------------------

	local FeatureCard = Components:CreateCard(

		LeftColumn,
		Theme,
		UDim2.new(1,0,0,370),
		UDim2.new()

	)

	FeatureCard.LayoutOrder = 1

	Components:CreateTitle(
		FeatureCard,
		Theme,
		"⚡ FEATURE GROUP CONTROLS"
	)

	local ToggleContainer = Instance.new("Frame")

	ToggleContainer.BackgroundTransparency = 1

	ToggleContainer.Position = UDim2.fromOffset(20,55)

	ToggleContainer.Size = UDim2.new(1,-40,0,220)

	ToggleContainer.Parent = FeatureCard

	local ToggleLayout = Instance.new("UIListLayout")

	ToggleLayout.Padding = UDim.new(0,8)

	ToggleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	ToggleLayout.Parent = ToggleContainer

	App.FeatureToggles = {}

	local Groups = {

		"👤 Player Features",

		"🛡 Guard Features",

		"🕵 Detective Features",

		"🌱 Farming Features",

		"👑 VIP Features"

	}

	for _,Name in ipairs(Groups) do

		local Holder, Toggle =
			Components:CreateToggle(
				ToggleContainer,
				Theme,
				Name
			)

		table.insert(
			App.FeatureToggles,
			Toggle
		)

	end

	----------------------------------------------------------
	-- Apply Features
	----------------------------------------------------------

	local ApplyButton =
		Components:CreateButton(
			FeatureCard,
			Theme,
			"▶ APPLY ENABLED FEATURES"
		)

	ApplyButton.Position = UDim2.new(0,20,1,-72)

	ApplyButton.Size = UDim2.new(1,-40,0,40)

	ApplyButton.MouseButton1Click:Connect(function()

		Notifications:Info(

			"Feature Groups",

			"Applying enabled feature groups...",

			2

		)

	end)

	----------------------------------------------------------
	-- Feature Footer
	----------------------------------------------------------

	local FeatureFooter = Instance.new("TextLabel")

	FeatureFooter.BackgroundTransparency = 1

	FeatureFooter.Position = UDim2.new(0,20,1,-26)

	FeatureFooter.Size = UDim2.new(1,-40,0,18)

	FeatureFooter.Font = Theme.Font

	FeatureFooter.TextSize = 12

	FeatureFooter.TextColor3 = Theme.SubText

	FeatureFooter.TextXAlignment = Enum.TextXAlignment.Center

	FeatureFooter.Text =
		"Enable groups here • Configure individual features later"

	FeatureFooter.Parent = FeatureCard

	----------------------------------------------------------
	-- Left Column Placeholder
	----------------------------------------------------------

	local Placeholder = Components:CreateCard(

		LeftColumn,
		Theme,
		UDim2.new(1,0,0,180),
		UDim2.new()

	)

	Placeholder.LayoutOrder = 2

	Components:CreateTitle(

		Placeholder,

		Theme,

		"📌 UPCOMING"

	)

	local PlaceholderText = Instance.new("TextLabel")

	PlaceholderText.BackgroundTransparency = 1

	PlaceholderText.Position = UDim2.fromOffset(20,55)

	PlaceholderText.Size = UDim2.new(1,-40,1,-70)

	PlaceholderText.Font = Theme.Font

	PlaceholderText.TextWrapped = true

	PlaceholderText.TextYAlignment = Enum.TextYAlignment.Top

	PlaceholderText.TextXAlignment = Enum.TextXAlignment.Left

	PlaceholderText.TextSize = 13

	PlaceholderText.TextColor3 = Theme.SubText

	PlaceholderText.Text =
		"This area is reserved for future dashboard widgets such as daily challenges, update notes, or featured tools."

	PlaceholderText.Parent = Placeholder

		----------------------------------------------------------
	-- Server Statistics
	----------------------------------------------------------

	local ServerCard = Components:CreateCard(

		MiddleColumn,
		Theme,
		UDim2.new(1,0,0,285),
		UDim2.new()

	)

	ServerCard.LayoutOrder = 1

	Components:CreateTitle(
		ServerCard,
		Theme,
		"📊 SERVER STATS"
	)

	local StatsHolder = Instance.new("Frame")

	StatsHolder.BackgroundTransparency = 1

	StatsHolder.Position = UDim2.fromOffset(20,55)

	StatsHolder.Size = UDim2.new(1,-40,1,-70)

	StatsHolder.Parent = ServerCard

	local StatsLayout = Instance.new("UIListLayout")

	StatsLayout.Padding = UDim.new(0,6)

	StatsLayout.Parent = StatsHolder

	local function NewStat(Text)

		local Label = Instance.new("TextLabel")

		Label.BackgroundTransparency = 1

		Label.Size = UDim2.new(1,0,0,18)

		Label.Font = Theme.Font

		Label.TextSize = 14

		Label.TextXAlignment = Enum.TextXAlignment.Left

		Label.TextColor3 = Theme.Text

		Label.Text = Text

		Label.Parent = StatsHolder

		return Label

	end

	local PingLabel = NewStat("Ping : 0 ms")
	local FPSLabel = NewStat("FPS : 0")
	local PlayerLabel = NewStat("Players : 0")
	local AgeLabel = NewStat("Server Age : 00:00")
	local StatusLabel = NewStat("Status : 🟢 Running")
	local BuildLabel = NewStat("Build : "..App.Version)

	RunService.RenderStepped:Connect(function()

		PingLabel.Text =
			"Ping : "..Utilities:GetPing().." ms"

		FPSLabel.Text =
			"FPS : "..Utilities:GetFPS()

		PlayerLabel.Text =
			"Players : "..Utilities:GetPlayerCount()

		AgeLabel.Text =
			"Server Age : "..Utilities:GetServerAge()

	end)

	----------------------------------------------------------
	-- Warning Panel
	----------------------------------------------------------

	local WarningCard = Components:CreateCard(

		MiddleColumn,
		Theme,
		UDim2.new(1,0,0,320),
		UDim2.new()

	)

	WarningCard.LayoutOrder = 2

	Components:CreateTitle(

		WarningCard,

		Theme,

		"⚠ CAUTION & SAFETY"

	)

	local WarningBar = Instance.new("Frame")

	WarningBar.Size = UDim2.new(1,0,0,4)

	WarningBar.BackgroundColor3 = Theme.Warning

	WarningBar.BorderSizePixel = 0

	WarningBar.Parent = WarningCard

	local WarningCorner = Instance.new("UICorner")

	WarningCorner.CornerRadius = UDim.new(1,0)

	WarningCorner.Parent = WarningBar

	local WarningText = Instance.new("TextLabel")

	WarningText.BackgroundTransparency = 1

	WarningText.Position = UDim2.fromOffset(20,55)

	WarningText.Size = UDim2.new(1,-40,1,-70)

	WarningText.Font = Theme.Font

	WarningText.TextWrapped = true

	WarningText.TextXAlignment = Enum.TextXAlignment.Left

	WarningText.TextYAlignment = Enum.TextYAlignment.Top

	WarningText.TextColor3 = Theme.SubText

	WarningText.TextSize = 13

	WarningText.Text =
[[• Some features are still experimental.

• Automation may increase your risk of moderation.

• Use features responsibly.

• Avoid obvious abuse in public servers.

• SquidNoMo cannot guarantee protection against future anti-cheat updates.

• Always test new features carefully before daily use.]]

	WarningText.Parent = WarningCard

		----------------------------------------------------------
	-- Support Development
	----------------------------------------------------------

	local SupportCard = Components:CreateCard(

		RightColumn,
		Theme,
		UDim2.new(1,0,0,310),
		UDim2.new()

	)

	SupportCard.LayoutOrder = 1

	Components:CreateTitle(
		SupportCard,
		Theme,
		"❤️ SUPPORT DEVELOPMENT"
	)

	local GoalLabel = Instance.new("TextLabel")

	GoalLabel.BackgroundTransparency = 1

	GoalLabel.Position = UDim2.fromOffset(20,55)

	GoalLabel.Size = UDim2.new(1,-40,0,18)

	GoalLabel.Font = Theme.FontBold

	GoalLabel.Text = "$0 / $100 Monthly Goal"

	GoalLabel.TextSize = 14

	GoalLabel.TextColor3 = Theme.Text

	GoalLabel.TextXAlignment = Enum.TextXAlignment.Left

	GoalLabel.Parent = SupportCard

	local ProgressBar = Instance.new("Frame")

	ProgressBar.Position = UDim2.fromOffset(20,82)

	ProgressBar.Size = UDim2.new(1,-40,0,14)

	ProgressBar.BackgroundColor3 = Theme.Card

	ProgressBar.BorderSizePixel = 0

	ProgressBar.Parent = SupportCard

	local ProgressCorner = Instance.new("UICorner")
	ProgressCorner.CornerRadius = UDim.new(1,0)
	ProgressCorner.Parent = ProgressBar

	local ProgressFill = Instance.new("Frame")

	ProgressFill.Size = UDim2.new(0,0,1,0)

	ProgressFill.BackgroundColor3 = Theme.Accent

	ProgressFill.BorderSizePixel = 0

	ProgressFill.Parent = ProgressBar

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1,0)
	FillCorner.Parent = ProgressFill

	local CashApp =
		Components:CreateButton(
			SupportCard,
			Theme,
			"💵 CashApp"
		)

	CashApp.Position = UDim2.fromOffset(20,115)

	CashApp.Size = UDim2.new(.47,-5,0,40)

	local PayPal =
		Components:CreateButton(
			SupportCard,
			Theme,
			"🅿 PayPal"
		)

	PayPal.Position = UDim2.new(.53,5,0,115)

	PayPal.Size = UDim2.new(.47,-5,0,40)

	local SupportInfo = Instance.new("TextLabel")

	SupportInfo.BackgroundTransparency = 1

	SupportInfo.Position = UDim2.fromOffset(20,170)

	SupportInfo.Size = UDim2.new(1,-40,0,100)

	SupportInfo.Font = Theme.Font

	SupportInfo.TextWrapped = true

	SupportInfo.TextYAlignment = Enum.TextYAlignment.Top

	SupportInfo.TextXAlignment = Enum.TextXAlignment.Left

	SupportInfo.TextSize = 13

	SupportInfo.TextColor3 = Theme.SubText

	SupportInfo.Text =
		"SquidNoMo is completely keyless and independently developed.\n\nEvery donation goes directly toward development, hosting, testing, and future updates."

	SupportInfo.Parent = SupportCard

	----------------------------------------------------------
	-- Quick Settings
	----------------------------------------------------------

	local QuickCard = Components:CreateCard(

		RightColumn,
		Theme,
		UDim2.new(1,0,0,250),
		UDim2.new()

	)

	QuickCard.LayoutOrder = 2

	Components:CreateTitle(
		QuickCard,
		Theme,
		"⚙ QUICK SETTINGS"
	)

	local QuickHolder = Instance.new("Frame")

	QuickHolder.BackgroundTransparency = 1

	QuickHolder.Position = UDim2.fromOffset(20,55)

	QuickHolder.Size = UDim2.new(1,-40,0,130)

	QuickHolder.Parent = QuickCard

	local QuickLayout = Instance.new("UIListLayout")

	QuickLayout.Padding = UDim.new(0,8)

	QuickLayout.Parent = QuickHolder

	Components:CreateToggle(
		QuickHolder,
		Theme,
		"Auto Attach"
	)

	Components:CreateToggle(
		QuickHolder,
		Theme,
		"Performance Mode"
	)

	Components:CreateToggle(
		QuickHolder,
		Theme,
		"Animations"
	)

	local SettingsButton =
		Components:CreateButton(
			QuickCard,
			Theme,
			"⚙ OPEN SETTINGS"
		)

	SettingsButton.Position = UDim2.new(0,20,1,-52)

	SettingsButton.Size = UDim2.new(1,-40,0,36)

	SettingsButton.MouseButton1Click:Connect(function()

		App:OpenPage("Settings")

	end)

	----------------------------------------------------------
	-- Dashboard Ready
	----------------------------------------------------------

	Notifications:Success(

		"Dashboard",

		"Home page loaded successfully.",

		2

	)

end

return Home
