--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Home.lua
--// Dashboard
--//========================================================--

local Home = {}

function Home:Create(Page, App)

	local Theme = App.Theme
	local Components = App.Components

	----------------------------------------------------------
	-- UIListLayout
	----------------------------------------------------------

	local Layout = Instance.new("UIListLayout")

	Layout.FillDirection = Enum.FillDirection.Vertical

	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	Layout.Padding = UDim.new(0,18)

	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	Layout.Parent = Page

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

	----------------------------------------------------------
	-- Banner Image
	----------------------------------------------------------

	local Artwork = Instance.new("ImageLabel")

	Artwork.Name = "Artwork"

	Artwork.BackgroundTransparency = 1

	Artwork.Size = UDim2.new(1,0,1,0)

	Artwork.Image = Theme.Assets.HeroImage

	Artwork.ScaleType = Enum.ScaleType.Crop

	Artwork.Parent = Banner

	local ArtworkCorner = Instance.new("UICorner")

	ArtworkCorner.CornerRadius = UDim.new(0,Theme.CardRadius)

	ArtworkCorner.Parent = Artwork

	----------------------------------------------------------
	-- Dark Overlay
	----------------------------------------------------------

	local Overlay = Instance.new("Frame")

	Overlay.BackgroundColor3 = Color3.new(0,0,0)

	Overlay.BackgroundTransparency = .45

	Overlay.Size = UDim2.fromScale(1,1)

	Overlay.Parent = Banner

	local OverlayCorner = Instance.new("UICorner")

	OverlayCorner.CornerRadius = UDim.new(0,Theme.CardRadius)

	OverlayCorner.Parent = Overlay

	----------------------------------------------------------
	-- Welcome Title
	----------------------------------------------------------

	local Title = Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position = UDim2.fromOffset(34,26)

	Title.Size = UDim2.new(.55,0,0,48)

	Title.Font = Theme.FontBlack

	Title.Text = "Welcome to\nSquidNoMo!"

	Title.TextColor3 = Theme.Text

	Title.TextSize = 34

	Title.TextXAlignment = Enum.TextXAlignment.Left

	Title.TextYAlignment = Enum.TextYAlignment.Top

	Title.Parent = Banner

	----------------------------------------------------------
	-- Description
	----------------------------------------------------------

	local Description = Instance.new("TextLabel")

	Description.BackgroundTransparency = 1

	Description.Position = UDim2.fromOffset(34,118)

	Description.Size = UDim2.new(.55,0,0,70)

	Description.Font = Theme.Font

	Description.TextWrapped = true

	Description.TextSize = 17

	Description.TextColor3 = Theme.SubText

	Description.TextXAlignment = Enum.TextXAlignment.Left

	Description.TextYAlignment = Enum.TextYAlignment.Top

	Description.Text =
		"SquidNoMo is the ultimate all-in-one companion for Squid Game X, bringing powerful automation and utilities together in one clean interface."

	Description.Parent = Banner

	----------------------------------------------------------
	-- Footer Tags
	----------------------------------------------------------

	local Tags = Instance.new("TextLabel")

	Tags.BackgroundTransparency = 1

	Tags.Position = UDim2.fromOffset(34,214)

	Tags.Size = UDim2.new(.6,0,0,24)

	Tags.Font = Theme.FontBold

	Tags.TextColor3 = Theme.Accent

	Tags.TextSize = 17

	Tags.TextXAlignment = Enum.TextXAlignment.Left

	Tags.Text =
		"Squid Game X   •   All-In-One Tool"

	Tags.Parent = Banner

	----------------------------------------------------------
	-- Main Content Row
	----------------------------------------------------------

	local Row = Instance.new("Frame")

	Row.Name = "TopRow"

	Row.BackgroundTransparency = 1

	Row.Size = UDim2.new(1,0,0,420)

	Row.LayoutOrder = 2

	Row.Parent = Page

	local RowLayout = Instance.new("UIListLayout")

	RowLayout.FillDirection = Enum.FillDirection.Horizontal

	RowLayout.Padding = UDim.new(0,18)

	RowLayout.Parent = Row

	----------------------------------------------------------
	-- Left Column
	----------------------------------------------------------

	local LeftColumn = Instance.new("Frame")

	LeftColumn.BackgroundTransparency = 1

	LeftColumn.Size = UDim2.new(.34,0,1,0)

	LeftColumn.Parent = Row

	----------------------------------------------------------
	-- Middle Column
	----------------------------------------------------------

	local MiddleColumn = Instance.new("Frame")

	MiddleColumn.BackgroundTransparency = 1

	MiddleColumn.Size = UDim2.new(.32,0,1,0)

	MiddleColumn.Parent = Row

	----------------------------------------------------------
	-- Right Column
	----------------------------------------------------------

	local RightColumn = Instance.new("Frame")

	RightColumn.BackgroundTransparency = 1

	RightColumn.Size = UDim2.new(.34,0,1,0)

	RightColumn.Parent = Row

	----------------------------------------------------------
	-- Save References
	----------------------------------------------------------

	self.LeftColumn = LeftColumn

	self.MiddleColumn = MiddleColumn

	self.RightColumn = RightColumn

  	----------------------------------------------------------
	-- Feature Group Controls
	----------------------------------------------------------

	local FeatureCard = Components:CreateCard(

		LeftColumn,
		Theme,
		UDim2.new(1,0,1,0),
		UDim2.new()

	)

	Components:CreateTitle(
		FeatureCard,
		Theme,
		"⚡ FEATURE GROUP CONTROLS"
	)

	local ToggleHolder = Instance.new("Frame")

	ToggleHolder.BackgroundTransparency = 1

	ToggleHolder.Position = UDim2.fromOffset(20,60)

	ToggleHolder.Size = UDim2.new(1,-40,0,250)

	ToggleHolder.Parent = FeatureCard

	local ToggleLayout = Instance.new("UIListLayout")

	ToggleLayout.Padding = UDim.new(0,8)

	ToggleLayout.Parent = ToggleHolder

	local ToggleData = {

		"👤 Player Features",

		"🛡️ Guard Features",

		"🕵 Detective Features",

		"🌱 Farming Features",

		"👑 VIP Features"

	}

	App.FeatureToggles = {}

	for _,Name in ipairs(ToggleData) do

		local Holder, Toggle =
			Components:CreateToggle(
				ToggleHolder,
				Theme,
				Name
			)

		table.insert(
			App.FeatureToggles,
			Toggle
		)

	end

	----------------------------------------------------------
	-- Apply Button
	----------------------------------------------------------

	local ApplyButton =
		Components:CreateButton(

			FeatureCard,

			Theme,

			"▶ APPLY ENABLED FEATURES"

		)

	ApplyButton.Position = UDim2.new(
		0,
		20,
		1,
		-70
	)

	ApplyButton.Size = UDim2.new(
		1,
		-40,
		0,
		42
	)

	ApplyButton.MouseButton1Click:Connect(function()

		App.Notifications:Info(

			"Feature Groups",

			"Applying enabled feature groups...",

			2

		)

	end)

	----------------------------------------------------------
	-- Footer Text
	----------------------------------------------------------

	local Footer = Instance.new("TextLabel")

	Footer.BackgroundTransparency = 1

	Footer.Position = UDim2.new(
		0,
		20,
		1,
		-24
	)

	Footer.Size = UDim2.new(
		1,
		-40,
		0,
		18
	)

	Footer.Font = Theme.Font

	Footer.Text =
		"Applies all enabled feature groups at once."

	Footer.TextColor3 = Theme.SubText

	Footer.TextSize = 12

	Footer.TextXAlignment = Enum.TextXAlignment.Center

	Footer.Parent = FeatureCard

  	----------------------------------------------------------
	-- Server Stats
	----------------------------------------------------------

	local ServerCard = Components:CreateCard(

		MiddleColumn,
		Theme,
		UDim2.new(1,0,0,300),
		UDim2.new()

	)

	Components:CreateTitle(
		ServerCard,
		Theme,
		"📊 SERVER STATS"
	)

	local StatsHolder = Instance.new("Frame")

	StatsHolder.BackgroundTransparency = 1

	StatsHolder.Position = UDim2.fromOffset(20,60)

	StatsHolder.Size = UDim2.new(1,-40,1,-80)

	StatsHolder.Parent = ServerCard

	local Layout = Instance.new("UIListLayout")

	Layout.Padding = UDim.new(0,6)

	Layout.Parent = StatsHolder

	local function CreateStat(Name, Value)

		local Label = Instance.new("TextLabel")

		Label.BackgroundTransparency = 1

		Label.Size = UDim2.new(1,0,0,20)

		Label.Font = Theme.FontMedium

		Label.TextXAlignment = Enum.TextXAlignment.Left

		Label.TextSize = 14

		Label.TextColor3 = Theme.Text

		Label.Text = Name .. ": " .. tostring(Value)

		Label.Parent = StatsHolder

		return Label

	end

	local StatusLabel = CreateStat("Status","🟢 Running")
	local PingLabel = CreateStat("Ping","0 ms")
	local FPSLabel = CreateStat("FPS","60")
	local PlayersLabel = CreateStat("Players","0")
	local AgeLabel = CreateStat("Server Age","00:00")
	local PlaceLabel = CreateStat("Place","Squid Game X")
	local RegionLabel = CreateStat("Region","Unknown")
	local VersionLabel = CreateStat("Version",App.Version)

	RunService.RenderStepped:Connect(function()

		PingLabel.Text =
			"Ping: "..Utilities:GetPing().." ms"

		FPSLabel.Text =
			"FPS: "..Utilities:GetFPS()

		PlayersLabel.Text =
			"Players: "..Utilities:GetPlayerCount()

		AgeLabel.Text =
			"Server Age: "..Utilities:GetServerAge()

	end)

  
	----------------------------------------------------------
	-- Warning Panel
	----------------------------------------------------------

	local WarningCard = Components:CreateCard(

		MiddleColumn,

		Theme,

		UDim2.new(1,0,0,260),

		UDim2.new()

	)

	WarningCard.Position = UDim2.new(0,0,0,320)

	Components:CreateTitle(

		WarningCard,

		Theme,

		"⚠ CAUTION & SAFETY"

	)

	local WarningText = Instance.new("TextLabel")

	WarningText.BackgroundTransparency = 1

	WarningText.Position = UDim2.fromOffset(20,58)

	WarningText.Size = UDim2.new(1,-40,1,-70)

	WarningText.Font = Theme.Font

	WarningText.TextSize = 14

	WarningText.TextWrapped = true

	WarningText.TextYAlignment = Enum.TextYAlignment.Top

	WarningText.TextXAlignment = Enum.TextXAlignment.Left

	WarningText.TextColor3 = Theme.SubText

	WarningText.Text =
[[• Some features are experimental and may not always behave as expected.

• Using automation or gameplay modifications may increase your risk of moderation or account penalties.

• Use features responsibly and avoid obvious abuse in public servers.

• SquidNoMo cannot guarantee protection from detection or future game updates.

• Always test new features carefully before relying on them.]]

	WarningText.Parent = WarningCard

	local WarningBar = Instance.new("Frame")

	WarningBar.Size = UDim2.new(1,0,0,4)

	WarningBar.BackgroundColor3 = Theme.Warning

	WarningBar.BorderSizePixel = 0

	WarningBar.Parent = WarningCard

	local BarCorner = Instance.new("UICorner")

	BarCorner.CornerRadius = UDim.new(1,0)

	BarCorner.Parent = WarningBar

	----------------------------------------------------------
	-- Support Development
	----------------------------------------------------------

	local SupportCard = Components:CreateCard(

		RightColumn,

		Theme,

		UDim2.new(1,0,0,360),

		UDim2.new()

	)

	Components:CreateTitle(

		SupportCard,

		Theme,

		"❤️ SUPPORT DEVELOPMENT"

	)

	Components:CreateSubtitle(

		SupportCard,

		Theme,

		"Keep SquidNoMo completely free."

	)

	----------------------------------------------------------
	-- Goal Text
	----------------------------------------------------------

	local GoalText = Instance.new("TextLabel")

	GoalText.BackgroundTransparency = 1

	GoalText.Position = UDim2.fromOffset(20,82)

	GoalText.Size = UDim2.new(1,-40,0,18)

	GoalText.Font = Theme.FontBold

	GoalText.Text = "$0 / $100 Monthly Goal"

	GoalText.TextColor3 = Theme.Text

	GoalText.TextSize = 14

	GoalText.TextXAlignment = Enum.TextXAlignment.Left

	GoalText.Parent = SupportCard

	----------------------------------------------------------
	-- Progress Bar
	----------------------------------------------------------

	local ProgressBar, Fill =
		Components:CreateProgressBar(
			SupportCard,
			Theme
		)

	ProgressBar.Position = UDim2.fromOffset(20,110)

	ProgressBar.Size = UDim2.new(1,-40,0,16)

	Fill.Size = UDim2.new(0,0,1,0)

	----------------------------------------------------------
	-- Donation Buttons
	----------------------------------------------------------

	local CashApp =
		Components:CreateButton(
			SupportCard,
			Theme,
			"💵 CashApp"
		)

	CashApp.Position = UDim2.fromOffset(20,145)

	CashApp.Size = UDim2.new(.47,-5,0,40)

	local PayPal =
		Components:CreateButton(
			SupportCard,
			Theme,
			"🅿 PayPal"
		)

	PayPal.Position = UDim2.new(.53,5,0,145)

	PayPal.Size = UDim2.new(.47,-5,0,40)

	CashApp.MouseButton1Click:Connect(function()

		App.Notifications:Info(

			"CashApp",

			"Opening CashApp support link...",

			2

		)

	end)

	PayPal.MouseButton1Click:Connect(function()

		App.Notifications:Info(

			"PayPal",

			"Opening PayPal support link...",

			2

		)

	end)

	----------------------------------------------------------
	-- Recent Supporters
	----------------------------------------------------------

	local RecentTitle = Instance.new("TextLabel")

	RecentTitle.BackgroundTransparency = 1

	RecentTitle.Position = UDim2.fromOffset(20,205)

	RecentTitle.Size = UDim2.new(1,-40,0,18)

	RecentTitle.Font = Theme.FontBold

	RecentTitle.Text = "Recent Supporters"

	RecentTitle.TextColor3 = Theme.Text

	RecentTitle.TextSize = 14

	RecentTitle.TextXAlignment = Enum.TextXAlignment.Left

	RecentTitle.Parent = SupportCard

	local Recent = Instance.new("TextLabel")

	Recent.BackgroundTransparency = 1

	Recent.Position = UDim2.fromOffset(20,230)

	Recent.Size = UDim2.new(1,-40,0,90)

	Recent.Font = Theme.Font

	Recent.TextWrapped = true

	Recent.TextYAlignment = Enum.TextYAlignment.Top

	Recent.TextXAlignment = Enum.TextXAlignment.Left

	Recent.TextColor3 = Theme.SubText

	Recent.Text =
		"No supporters yet.\nBe the first to help keep SquidNoMo free!"

	Recent.TextSize = 13

	Recent.Parent = SupportCard

  	----------------------------------------------------------
	-- Quick Settings
	----------------------------------------------------------

	local QuickCard = Components:CreateCard(

		RightColumn,

		Theme,

		UDim2.new(1,0,0,250),

		UDim2.new()

	)

	QuickCard.Position = UDim2.new(0,0,0,380)

	Components:CreateTitle(

		QuickCard,

		Theme,

		"⚙ QUICK SETTINGS"

	)

	Components:CreateSubtitle(

		QuickCard,

		Theme,

		"Frequently used options."

	)

	local QuickHolder = Instance.new("Frame")

	QuickHolder.BackgroundTransparency = 1

	QuickHolder.Position = UDim2.fromOffset(20,60)

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

	local OpenSettings =
		Components:CreateButton(
			QuickCard,
			Theme,
			"⚙ OPEN SETTINGS"
		)

	OpenSettings.Position = UDim2.new(
		0,
		20,
		1,
		-52
	)

	OpenSettings.Size = UDim2.new(
		1,
		-40,
		0,
		36
	)

	OpenSettings.MouseButton1Click:Connect(function()

		App:OpenPage("Settings")

	end)
  
	self.Page = Page

  	----------------------------------------------------------
	-- Dashboard Footer
	----------------------------------------------------------

	local Footer = Instance.new("TextLabel")

	Footer.Name = "DashboardFooter"

	Footer.BackgroundTransparency = 1

	Footer.Size = UDim2.new(1,0,0,22)

	Footer.LayoutOrder = 99

	Footer.Font = Theme.Font

	Footer.Text = "SquidNoMo Beta 4.0 • Developed by NOMO • Keyless • Experimental Build"

	Footer.TextColor3 = Theme.SubText

	Footer.TextSize = 12

	Footer.TextXAlignment = Enum.TextXAlignment.Center

	Footer.Parent = Page

	----------------------------------------------------------
	-- Dashboard Refresh Loop
	----------------------------------------------------------

	task.spawn(function()

		while Page.Parent do

			-- Future live updates will go here.
			-- Examples:
			-- Donation Goal
			-- Server Health
			-- Script Health
			-- Feature Status
			-- AI Suggestions

			task.wait(1)

		end

	end)

	----------------------------------------------------------
	-- Dashboard Ready
	----------------------------------------------------------

	App.Notifications:Success(

		"Dashboard Ready",

		"Home page loaded successfully.",

		2

  )

end

return Home

