--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// Init.lua
--//========================================================--

local Player = {}

----------------------------------------------------------
-- Loader
----------------------------------------------------------

local function Load(ModuleName)

	return loadstring(game:HttpGet(

		App.Config.Repository ..
		"Features/Player/" ..
		ModuleName ..
		".lua"

	))()

end

----------------------------------------------------------
-- Enhancement Features
----------------------------------------------------------

Player.WalkSpeed = Load("WalkSpeed")

Player.JumpPower = Load("JumpPower")

Player.InfiniteJump = Load("InfiniteJump")

Player.Noclip = Load("Noclip")

----------------------------------------------------------
-- ESP Features
----------------------------------------------------------

Player.PlayerESP = Load("PlayerESP")

Player.GuardESP = Load("GuardESP")

Player.DetectiveESP = Load("DetectiveESP")

Player.FrontmanESP = Load("FrontmanESP")

----------------------------------------------------------
-- Utility Features
----------------------------------------------------------

Player.AntiAFK = Load("AntiAFK")

Player.AntiLag = Load("AntiLag")

Player.Reset = Load("Reset")

Player.Rejoin = Load("Rejoin")

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Player
