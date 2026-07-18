--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// FeatureManager.lua
--//========================================================--

local FeatureManager = {}

----------------------------------------------------------
-- Load Helper
----------------------------------------------------------

local function Load(App, Path)

	return loadstring(game:HttpGet(

		App.Config.Repository .. Path

	))()

end

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function FeatureManager:Initialize(App)

	local Features = {}

	------------------------------------------------------
	-- Shared
	------------------------------------------------------

	Features.Shared = {}

	Features.Shared.RoleService = Load(
		App,
		"Features/Shared/RoleService.lua"
	)

	------------------------------------------------------
	-- Player
	------------------------------------------------------

	Features.Player = Load(
		App,
		"Features/Player/Init.lua"
	)

	self.Features = Features

	return Features

end

----------------------------------------------------------
-- Get
----------------------------------------------------------

function FeatureManager:Get()

	return self.Features

end

return FeatureManager
