local RemoveAtmosphere = {}
local Lighting = game:GetService("Lighting")

local Enabled = false
local States = {}
local Connection = nil

local function apply(object)
    if not object:IsA("Atmosphere") then return end
    if not States[object] then
        States[object] = {
            Density = object.Density,
            Haze = object.Haze,
            Glare = object.Glare,
        }
    end
    object.Density = 0
    object.Haze = 0
    object.Glare = 0
end

function RemoveAtmosphere:Enable()
    if Enabled then return end
    Enabled = true
    for _, child in ipairs(Lighting:GetChildren()) do
        apply(child)
    end
    Connection = Lighting.ChildAdded:Connect(function(child)
        if Enabled then apply(child) end
    end)
end

function RemoveAtmosphere:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    for object, state in pairs(States) do
        if object and object.Parent then
            object.Density = state.Density
            object.Haze = state.Haze
            object.Glare = state.Glare
        end
    end
    table.clear(States)
end

function RemoveAtmosphere:IsEnabled() return Enabled end
function RemoveAtmosphere:GetState() return Enabled and "on" or "off" end

return RemoveAtmosphere
