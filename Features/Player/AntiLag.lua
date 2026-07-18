--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// AntiLag.lua
--//========================================================--

local AntiLag = {}

local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain

local Enabled = false

local Defaults = {}

----------------------------------------------------------
-- Save Defaults
----------------------------------------------------------

local function SaveDefaults()

	if Defaults.Saved then
		return
	end

	Defaults.Saved = true

	Defaults.GlobalShadows = Lighting.GlobalShadows
	Defaults.Brightness = Lighting.Brightness
	Defaults.FogEnd = Lighting.FogEnd

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function AntiLag:Enable()

	if Enabled then
		return
	end

	Enabled = true

	SaveDefaults()

	Lighting.GlobalShadows = false
	Lighting.Brightness = 1
	Lighting.FogEnd = 100000

	pcall(function()
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
	end)

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("ParticleEmitter")
		or object:IsA("Trail")
		or object:IsA("Beam") then

			object.Enabled = false

		elseif object:IsA("Explosion") then

			object.Visible = false

		end

	end

end

----------------------------------------------------------
-- Disable
----------------------------------------------------------

function AntiLag:Disable()

	if not Enabled then
		return
	end

	Enabled = false

	if Defaults.Saved then

		Lighting.GlobalShadows = Defaults.GlobalShadows
		Lighting.Brightness = Defaults.Brightness
		Lighting.FogEnd = Defaults.FogEnd

	end

end

----------------------------------------------------------
-- Status
----------------------------------------------------------

function AntiLag:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return AntiLag
