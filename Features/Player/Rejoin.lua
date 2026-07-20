--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Player
--// Rejoin.lua
--//========================================================--

local Rejoin = {}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------
-- Execute
----------------------------------------------------------

function Rejoin:Execute()

	if not game.PlaceId then
		return
	end

	TeleportService:Teleport(
		game.PlaceId,
		LocalPlayer
	)

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Rejoin
