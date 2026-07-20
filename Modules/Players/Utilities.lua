--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Players
--// Utilities.lua
--//========================================================--

local Utilities = {}

----------------------------------------------------------
-- Create
----------------------------------------------------------

function Utilities:Create(Page, App)

	local Theme = App.Theme
	local Components = App.Components

	Page:ClearAllChildren()

	----------------------------------------------------------
	-- Layout
	----------------------------------------------------------

	local Layout = Instance.new("UIListLayout")

	Layout.FillDirection = Enum.FillDirection.Vertical
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0,16)

	Layout.Parent = Page

	----------------------------------------------------------
	-- Utilities Card
	----------------------------------------------------------

	local Card = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,340)

	)

	Card.LayoutOrder = 1

	Components:CreateTitle(

		Card,
		Theme,
		"🛠 Player Utilities"

	)

	local Holder = Instance.new("Frame")

	Holder.BackgroundTransparency = 1

	Holder.Position = UDim2.fromOffset(20,55)

	Holder.Size = UDim2.new(1,-40,1,-75)

	Holder.Parent = Card

	local HolderLayout = Instance.new("UIListLayout")

	HolderLayout.Padding = UDim.new(0,12)

	HolderLayout.Parent = Holder

  	----------------------------------------------------------
	-- Anti AFK
	----------------------------------------------------------

	local _, AntiAFK =
		Components:CreateToggle(

			Holder,
			Theme,
			"Anti AFK"

		)

	AntiAFK:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.AntiAFK then

			if State then
				App.Features.Player.AntiAFK:Enable()
			else
				App.Features.Player.AntiAFK:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Anti Lag
	----------------------------------------------------------

	local _, AntiLag =
		Components:CreateToggle(

			Holder,
			Theme,
			"Anti Lag"

		)

	AntiLag:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.AntiLag then

			if State then
				App.Features.Player.AntiLag:Enable()
			else
				App.Features.Player.AntiLag:Disable()
			end

		end

	end)

  	----------------------------------------------------------
	-- Reset Character
	----------------------------------------------------------

	local ResetButton =
		Components:CreateButton(

			Holder,
			Theme,
			"🔄 Reset Character"

		)

	ResetButton.MouseButton1Click:Connect(function()

		if App.Features
		and App.Features.Player
		and App.Features.Player.Reset then

			App.Features.Player.Reset:Execute()

		end

	end)

	----------------------------------------------------------
	-- Rejoin Server
	----------------------------------------------------------

	local RejoinButton =
		Components:CreateButton(

			Holder,
			Theme,
			"🌐 Rejoin Server"

		)

	RejoinButton.MouseButton1Click:Connect(function()

		if App.Features
		and App.Features.Player
		and App.Features.Player.Rejoin then

			App.Features.Player.Rejoin:Execute()

		end

	end)

	----------------------------------------------------------
	-- Finished
	----------------------------------------------------------

end

----------------------------------------------------------
-- Return Module
----------------------------------------------------------

return Utilities
