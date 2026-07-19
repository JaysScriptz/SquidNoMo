--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// JumpPower.lua
--//========================================================--

local JumpPower = {}

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local DefaultJumpPower = 50
local CurrentJumpPower = DefaultJumpPower

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

	Humanoid.UseJumpPower = true
	Humanoid.JumpPower = CurrentJumpPower

end

----------------------------------------------------------
-- Set Jump Power
----------------------------------------------------------

function JumpPower:Set(Value)

	CurrentJumpPower = Value

	Apply()

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function JumpPower:Reset()

	CurrentJumpPower = DefaultJumpPower

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

function JumpPower:Get()

	return CurrentJumpPower

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return JumpPower
