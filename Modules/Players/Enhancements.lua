--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Players
--// Enhancements.lua
--//========================================================--

local Enhancements = {}

----------------------------------------------------------
-- Create
----------------------------------------------------------

function Enhancements:Create(Page, App)

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
	-- Enhancement Card
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
		"✨ Player Enhancements"

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
	-- Walk Speed
	----------------------------------------------------------

	local WalkSpeed =
		Components:CreateSlider(

			Holder,
			Theme,
			"Walk Speed",
			16,
			100,
			16

		)

	WalkSpeed:OnChanged(function(Value)

		if App.Features
		and App.Features.Player
		and App.Features.Player.WalkSpeed then

			App.Features.Player.WalkSpeed:Set(Value)

		end

	end)

	----------------------------------------------------------
	-- Jump Power
	----------------------------------------------------------

	local JumpPower =
		Components:CreateSlider(

			Holder,
			Theme,
			"Jump Power",
			50,
			200,
			50

		)

	JumpPower:OnChanged(function(Value)

		if App.Features
		and App.Features.Player
		and App.Features.Player.JumpPower then

			App.Features.Player.JumpPower:Set(Value)

		end

	end)

  	----------------------------------------------------------
	-- Infinite Jump
	----------------------------------------------------------

	local _, InfiniteJump =
		Components:CreateToggle(

			Holder,
			Theme,
			"Infinite Jump"

		)

	InfiniteJump:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.InfiniteJump then

			if State then
				App.Features.Player.InfiniteJump:Enable()
			else
				App.Features.Player.InfiniteJump:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Noclip
	----------------------------------------------------------

	local _, Noclip =
		Components:CreateToggle(

			Holder,
			Theme,
			"Noclip"

		)

	Noclip:OnChanged(function(State)

		if App.Features
		and App.Features.Player
		and App.Features.Player.Noclip then

			if State then
				App.Features.Player.Noclip:Enable()
			else
				App.Features.Player.Noclip:Disable()
			end

		end

	end)

	----------------------------------------------------------
	-- Finished
	----------------------------------------------------------

end

return Enhancements
