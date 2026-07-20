local AntiLag = {}

local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

local Enabled = false
local TerrainDefaults = nil
local ExplosionStates = {}
local Connection = nil

local function applyExplosion(object)
    if not object:IsA("Explosion") then return end
    local ok, visible = pcall(function()
        return object.Visible
    end)
    if not ok then return end
    if ExplosionStates[object] == nil then
        ExplosionStates[object] = visible
    end
    pcall(function()
        object.Visible = false
    end)
end

function AntiLag:Enable()
    if Enabled then return end
    Enabled = true

    TerrainDefaults = {
        WaterWaveSize = Terrain.WaterWaveSize,
        WaterWaveSpeed = Terrain.WaterWaveSpeed,
        WaterReflectance = Terrain.WaterReflectance,
        WaterTransparency = Terrain.WaterTransparency,
    }

    pcall(function()
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end)

    for _, object in ipairs(Workspace:GetDescendants()) do
        applyExplosion(object)
    end

    Connection = Workspace.DescendantAdded:Connect(function(object)
        if Enabled then applyExplosion(object) end
    end)
end

function AntiLag:Disable()
    Enabled = false

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if TerrainDefaults then
        pcall(function()
            Terrain.WaterWaveSize = TerrainDefaults.WaterWaveSize
            Terrain.WaterWaveSpeed = TerrainDefaults.WaterWaveSpeed
            Terrain.WaterReflectance = TerrainDefaults.WaterReflectance
            Terrain.WaterTransparency = TerrainDefaults.WaterTransparency
        end)
    end
    TerrainDefaults = nil

    for object, visible in pairs(ExplosionStates) do
        if object and object.Parent then
            pcall(function()
                object.Visible = visible
            end)
        end
    end
    table.clear(ExplosionStates)
end

function AntiLag:IsEnabled()
    return Enabled
end

function AntiLag:GetState()
    return Enabled and "on" or "off"
end

return AntiLag
