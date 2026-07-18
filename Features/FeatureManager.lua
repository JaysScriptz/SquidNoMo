--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// Init.lua
--//========================================================--

local Player = {}

----------------------------------------------------------
-- Load Helper
----------------------------------------------------------

local function Load(Module)

	return loadstring(game:HttpGet(

		App.Config.Repository ..
		"Features/Player/" ..
		Module ..
		".lua"

	))()

end

----------------------------------------------------------
-- Enhancements
----------------------------------------------------------

Player.WalkSpeed     = Load("WalkSpeed")
Player.JumpPower     = Load("JumpPower")
Player.InfiniteJump  = Load("InfiniteJump")
Player.Noclip        = Load("Noclip")

----------------------------------------------------------
-- ESP
----------------------------------------------------------

Player.PlayerESP     = Load("PlayerESP")
Player.GuardESP      = Load("GuardESP")
Player.DetectiveESP  = Load("DetectiveESP")
Player.FrontmanESP   = Load("FrontmanESP")

----------------------------------------------------------
-- Utilities
----------------------------------------------------------

Player.AntiAFK       = Load("AntiAFK")
Player.AntiLag       = Load("AntiLag")
Player.Reset         = Load("Reset")
Player.Rejoin        = Load("Rejoin")

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Player
