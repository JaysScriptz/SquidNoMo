local RemoveFog = {}
local Lighting = game:GetService("Lighting")

local Enabled = false
local Defaults = nil

function RemoveFog:Enable()
    if Enabled then return end
    Enabled = true
    Defaults = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
    }
    Lighting.FogStart = 100000
    Lighting.FogEnd = 1000000
end

function RemoveFog:Disable()
    if not Enabled then return end
    Enabled = false
    if Defaults then
        Lighting.FogStart = Defaults.FogStart
        Lighting.FogEnd = Defaults.FogEnd
        Lighting.FogColor = Defaults.FogColor
    end
    Defaults = nil
end

function RemoveFog:IsEnabled() return Enabled end
function RemoveFog:GetState() return Enabled and "on" or "off" end

return RemoveFog
