--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// Init.lua
--//========================================================--

local Player = {}

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Player:Initialize(Loader)

	local function Load(Module)

		return loadstring(game:HttpGet(

			Loader.Config.Repository ..
			"Features/Player/" ..
			Module ..
			".lua"

		))()

	end

	------------------------------------------------------
	-- Enhancements
	------------------------------------------------------

	self.WalkSpeed = Load("WalkSpeed")

	self.JumpPower = Load("JumpPower")

	self.InfiniteJump = Load("InfiniteJump")

	self.Noclip = Load("Noclip")

	------------------------------------------------------
	-- ESP
	------------------------------------------------------

	self.PlayerESP = Load("PlayerESP")

	self.GuardESP = Load("GuardESP")

	self.DetectiveESP = Load("DetectiveESP")

	self.FrontmanESP = Load("FrontmanESP")

	------------------------------------------------------
	-- Utilities
	------------------------------------------------------

	self.AntiAFK = Load("AntiAFK")

	self.AntiLag = Load("AntiLag")

	self.Reset = Load("Reset")

	self.Rejoin = Load("Rejoin")

	return self

end

----------------------------------------------------------

return Player
