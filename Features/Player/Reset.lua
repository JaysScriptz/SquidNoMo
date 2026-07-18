--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// Reset.lua
--//========================================================--

local Reset = {}

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------
-- Execute
----------------------------------------------------------

function Reset:Execute()

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then

		Humanoid.Health = 0

	end

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Reset
