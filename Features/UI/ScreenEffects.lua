local ScreenEffects = {}
local Lighting = game:GetService("Lighting")
local Enabled = false
local States = {}
local Connection = nil

local function supported(effect)
    if effect.Name == "SquidNoMo_HighContrast" then
        return false
    end
    return effect:IsA("BloomEffect")
        or effect:IsA("SunRaysEffect")
        or effect:IsA("DepthOfFieldEffect")
        or effect:IsA("ColorCorrectionEffect")
end

local function disable(effect)
    if supported(effect) then
        if States[effect] == nil then States[effect] = effect.Enabled end
        effect.Enabled = false
    end
end

function ScreenEffects:Enable()
    if Enabled then return end
    Enabled = true
    for _, child in ipairs(Lighting:GetChildren()) do disable(child) end
    Connection = Lighting.ChildAdded:Connect(function(child)
        if Enabled then disable(child) end
    end)
end

function ScreenEffects:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    for effect, state in pairs(States) do
        if effect and effect.Parent then effect.Enabled = state end
    end
    table.clear(States)
end

function ScreenEffects:IsEnabled() return Enabled end
function ScreenEffects:GetState() return Enabled and "on" or "off" end
return ScreenEffects
