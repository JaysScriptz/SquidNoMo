--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Players
--// ESP.lua
--//========================================================--

local ESP = {}

----------------------------------------------------------
-- Create
----------------------------------------------------------

function ESP:Create(Page, App)

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
	-- ESP Card
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
		"👁 Role ESP"

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
	-- Player ESP
	----------------------------------------------------------

	local _, PlayerESP =
		Components:CreateToggle(

			Holder,
			Theme,
			"Player ESP"

		)

	PlayerESP:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.PlayerESP then

			if State then
				App.Features.Player.PlayerESP:Enable()
			else
				App.Features.Player.PlayerESP:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Guard ESP
	----------------------------------------------------------

	local _, GuardESP =
		Components:CreateToggle(

			Holder,
			Theme,
			"Guard ESP"

		)

	GuardESP:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.GuardESP then

			if State then
				App.Features.Player.GuardESP:Enable()
			else
				App.Features.Player.GuardESP:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Detective ESP
	----------------------------------------------------------

	local _, DetectiveESP =
		Components:CreateToggle(

			Holder,
			Theme,
			"Detective ESP"

		)

	DetectiveESP:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.DetectiveESP then

			if State then
				App.Features.Player.DetectiveESP:Enable()
			else
				App.Features.Player.DetectiveESP:Disable()
			end

		end

	end)

  	----------------------------------------------------------
	-- Frontman ESP
	----------------------------------------------------------

	local _, FrontmanESP =
		Components:CreateToggle(

			Holder,
			Theme,
			"Frontman ESP"

		)

	FrontmanESP:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.FrontmanESP then

			if State then
				App.Features.Player.FrontmanESP:Enable()
			else
				App.Features.Player.FrontmanESP:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Finished
	----------------------------------------------------------

end

----------------------------------------------------------
-- Return Module
----------------------------------------------------------

return ESP
