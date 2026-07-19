--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// FeatureManager.lua
--//========================================================--

local FeatureManager = {}

----------------------------------------------------------
-- Load Helper
----------------------------------------------------------

local function Load(Loader, Path)

	return loadstring(game:HttpGet(

		Loader.Config.Repository ..
		Path

	))()

end

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function FeatureManager:Initialize(Loader)

	local Features = {}

	------------------------------------------------------
	-- Shared
	------------------------------------------------------

	Features.Shared = {}

	Features.Shared.RoleService = Load(

		Loader,
		"Features/Shared/RoleService.lua"

	)

	-- Expose shared dependencies before player modules initialize.
	Loader.Features = Features

	------------------------------------------------------
	-- Player
	------------------------------------------------------

	Features.Player = Load(

		Loader,
		"Features/Player/Init.lua"

	)

	Features.Player:Initialize(Loader)

	------------------------------------------------------

	self.Features = Features

	Loader.Features = Features

	return Features

end

----------------------------------------------------------
-- Get
----------------------------------------------------------

function FeatureManager:Get()

	return self.Features

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return FeatureManager
