--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Players.lua
--//========================================================--

local PlayersPage = {}

----------------------------------------------------------
-- Create
----------------------------------------------------------

function PlayersPage:Create(Page, App)

	local Theme = App.Theme
	local Components = App.Components
	local Notifications = App.Notifications

	Page.BackgroundTransparency = 1


	------------------------------------------------------
	-- Banner
	------------------------------------------------------

	local Banner = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,120)

	)

	Banner.LayoutOrder = 1

	Components:CreateTitle(

		Banner,
		Theme,
		"👤 PLAYER FEATURES"

	)

	local Description = Instance.new("TextLabel")

	Description.BackgroundTransparency = 1
	Description.Position = UDim2.fromOffset(20,46)
	Description.Size = UDim2.new(1,-40,0,50)

	Description.Font = Theme.Font
	Description.TextWrapped = true
	Description.TextSize = 14

	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top

	Description.TextColor3 = Theme.SubText

	Description.Text =
		"Movement enhancements, ESP tools, and player utilities."

	Description.Parent = Banner

	------------------------------------------------------
	-- Movement Card
	------------------------------------------------------

	local MovementCard = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,260)

	)

	MovementCard.LayoutOrder = 2

	local Movement = Components:CreateSection(

		MovementCard,
		Theme,
		"🏃 Movement"

  )

  	------------------------------------------------------
	-- Walk Speed
	------------------------------------------------------

	local _, WalkSpeed =
		Components:CreateSlider(

			Movement,
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

	------------------------------------------------------
	-- Jump Power
	------------------------------------------------------

	local _, JumpPower =
		Components:CreateSlider(

			Movement,
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

	------------------------------------------------------
	-- Infinite Jump
	------------------------------------------------------

	local _, InfiniteJump =
		Components:CreateToggle(

			Movement,
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

	------------------------------------------------------
	-- Noclip
	------------------------------------------------------

	local _, Noclip =
		Components:CreateToggle(

			Movement,
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

  	------------------------------------------------------
	-- ESP Card
	------------------------------------------------------

	local ESPCard = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,250)

	)

	ESPCard.LayoutOrder = 3

	local ESP = Components:CreateSection(

		ESPCard,
		Theme,
		"👁 ESP"

	)

	------------------------------------------------------
	-- Player ESP
	------------------------------------------------------

	local _, PlayerESP =
		Components:CreateToggle(

			ESP,
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

	------------------------------------------------------
	-- Guard ESP
	------------------------------------------------------

	local _, GuardESP =
		Components:CreateToggle(

			ESP,
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

	------------------------------------------------------
	-- Detective ESP
	------------------------------------------------------

	local _, DetectiveESP =
		Components:CreateToggle(

			ESP,
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

	------------------------------------------------------
	-- Frontman ESP
	------------------------------------------------------

	local _, FrontmanESP =
		Components:CreateToggle(

			ESP,
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

  	------------------------------------------------------
	-- Utilities Card
	------------------------------------------------------

	local UtilityCard = Components:CreateCard(

		Page,
		Theme,
		UDim2.new(1,0,0,235)

	)

	UtilityCard.LayoutOrder = 4

	local Utility = Components:CreateSection(

		UtilityCard,
		Theme,
		"🛠 Utilities"

	)

	------------------------------------------------------
	-- Anti AFK
	------------------------------------------------------

	local _, AntiAFK =
		Components:CreateToggle(

			Utility,
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

------------------------------------------------------
-- Anti Lag
------------------------------------------------------

local _, AntiLag =
	Components:CreateToggle(

		Utility,
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
	
	------------------------------------------------------
	-- Reset Character
	------------------------------------------------------

	local ResetButton = Components:CreateButton(

		Utility,
		Theme,
		"Reset Character"

	)

	ResetButton.MouseButton1Click:Connect(function()

		if App.Features
		and App.Features.Player
		and App.Features.Player.Reset then

			App.Features.Player.Reset:Execute()

		else

			local Character = game.Players.LocalPlayer.Character

			if Character then

				local Humanoid =
					Character:FindFirstChildOfClass("Humanoid")

				if Humanoid then
					Humanoid.Health = 0
				end

			end

		end

	end)

	------------------------------------------------------
	-- Rejoin Server
	------------------------------------------------------

	local RejoinButton = Components:CreateButton(

		Utility,
		Theme,
		"Rejoin Server"

	)

	RejoinButton.MouseButton1Click:Connect(function()

		if App.Features
		and App.Features.Player
		and App.Features.Player.Rejoin then

			App.Features.Player.Rejoin:Execute()

		end

	end)

	------------------------------------------------------
	-- Players Page Ready
	------------------------------------------------------

	Notifications:Success(

		"Players",

		"Players page loaded.",

		2

	)

end

----------------------------------------------------------

return PlayersPage
