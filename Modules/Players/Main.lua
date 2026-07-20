--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Players
--// Main.lua
--//========================================================--

local PlayersMain = {}

----------------------------------------------------------
-- Create
----------------------------------------------------------

function PlayersMain:Create(Page, App)

	local Theme = App.Theme
	local Components = App.Components

	Page:ClearAllChildren()

	----------------------------------------------------------
	-- Main Layout
	----------------------------------------------------------

	local Layout = Instance.new("UIListLayout")

	Layout.FillDirection = Enum.FillDirection.Vertical
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0,16)

	Layout.Parent = Page

	----------------------------------------------------------
	-- Top Navigation Card
	----------------------------------------------------------

	local NavCard = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,64)

	)

	NavCard.LayoutOrder = 1

	----------------------------------------------------------
	-- Navigation Container
	----------------------------------------------------------

	local NavContainer = Instance.new("Frame")

	NavContainer.Name = "Navigation"

	NavContainer.BackgroundTransparency = 1

	NavContainer.Size = UDim2.new(1,-24,1,-16)

	NavContainer.Position = UDim2.fromOffset(12,8)

	NavContainer.Parent = NavCard

	local NavLayout = Instance.new("UIListLayout")

	NavLayout.FillDirection = Enum.FillDirection.Horizontal

	NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	NavLayout.Padding = UDim.new(0,14)

	NavLayout.Parent = NavContainer

	----------------------------------------------------------
	-- Content Area
	----------------------------------------------------------

	local Content = Instance.new("Frame")

	Content.Name = "Content"

	Content.BackgroundTransparency = 1

	Content.Size = UDim2.new(1,0,1,-80)

	Content.AutomaticSize = Enum.AutomaticSize.Y

	Content.LayoutOrder = 2

	Content.Parent = Page

	self.Content = Content
	self.NavContainer = NavContainer

  	----------------------------------------------------------
	-- Navigation Buttons
	----------------------------------------------------------

	local CurrentTab

	local Buttons = {}

	local function CreateTab(Name, Icon)

		local Button = Instance.new("TextButton")

		Button.Name = Name

		Button.Size = UDim2.fromOffset(170,44)

		Button.BackgroundColor3 = Theme.Card

		Button.BorderSizePixel = 0

		Button.AutoButtonColor = false

		Button.Font = Theme.FontBold

		Button.TextSize = 16

		Button.Text = Icon .. "  " .. Name

		Button.TextColor3 = Theme.Text

		Button.Parent = NavContainer

		local Corner = Instance.new("UICorner")

		Corner.CornerRadius = UDim.new(0,12)

		Corner.Parent = Button

		Buttons[Name] = Button

		return Button

	end

	local EnhancementsButton =
		CreateTab("Enhancements","✨")

	local ESPButton =
		CreateTab("ESP","👁")

	local UtilitiesButton =
		CreateTab("Utilities","🛠")

  	----------------------------------------------------------
	-- Page Loader
	----------------------------------------------------------

	local CurrentPage

	local function ClearPage()

		if CurrentPage then

			CurrentPage:Destroy()

			CurrentPage = nil

		end

	end

	local function SelectTab(Name)

		CurrentTab = Name

		for TabName, Button in pairs(Buttons) do

			if TabName == Name then

				Button.BackgroundColor3 = Theme.Accent
				Button.TextColor3 = Theme.Background

			else

				Button.BackgroundColor3 = Theme.Card
				Button.TextColor3 = Theme.Text

			end

		end

		ClearPage()

		CurrentPage = Instance.new("Frame")

		CurrentPage.Name = Name

		CurrentPage.BackgroundTransparency = 1

		CurrentPage.Size = UDim2.fromScale(1,1)

		CurrentPage.Parent = Content

		if Name == "Enhancements" then

			local Module = loadstring(game:HttpGet(

				App.Config.Repository ..
				"Modules/Players/Enhancements.lua"

			))()

			Module:Create(CurrentPage, App)

		elseif Name == "ESP" then

			local Module = loadstring(game:HttpGet(

				App.Config.Repository ..
				"Modules/Players/ESP.lua"

			))()

			Module:Create(CurrentPage, App)

		elseif Name == "Utilities" then

			local Module = loadstring(game:HttpGet(

				App.Config.Repository ..
				"Modules/Players/Utilities.lua"

			))()

			Module:Create(CurrentPage, App)

		end

  end
	----------------------------------------------------------
	-- Navigation Events
	----------------------------------------------------------

	EnhancementsButton.MouseButton1Click:Connect(function()

		SelectTab("Enhancements")

	end)

	ESPButton.MouseButton1Click:Connect(function()

		SelectTab("ESP")

	end)

	UtilitiesButton.MouseButton1Click:Connect(function()

		SelectTab("Utilities")

	end)

	----------------------------------------------------------
	-- Default Page
	----------------------------------------------------------

	SelectTab("Enhancements")

end

----------------------------------------------------------
-- Return Module
----------------------------------------------------------

return PlayersMain
  
