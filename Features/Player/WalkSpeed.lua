--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// WalkSpeed.lua
--//========================================================--

local WalkSpeed = {}

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DefaultSpeed = 16

local CurrentSpeed = DefaultSpeed

----------------------------------------------------------
-- Apply
----------------------------------------------------------

local function Apply()

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		return
	end

	Humanoid.WalkSpeed = CurrentSpeed

end

----------------------------------------------------------
-- Set Speed
----------------------------------------------------------

function WalkSpeed:Set(Value)

	CurrentSpeed = Value

	Apply()

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function WalkSpeed:Reset()

	CurrentSpeed = DefaultSpeed

	Apply()

end

----------------------------------------------------------
-- Character Respawn
----------------------------------------------------------

LocalPlayer.CharacterAdded:Connect(function()

	task.wait(0.25)

	Apply()

end)

----------------------------------------------------------
-- Current Value (dashboard state)
----------------------------------------------------------

function WalkSpeed:Get()

	return CurrentSpeed

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return WalkSpeed
