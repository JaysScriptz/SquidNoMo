local Fullbright = {}
local Lighting = game:GetService("Lighting")
local Enabled = false
local Defaults = nil

function Fullbright:Enable()
    if Enabled then return end
    Enabled = true
    Defaults = Defaults or {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
end

function Fullbright:Disable()
    if not Enabled then return end
    Enabled = false
    if Defaults then
        for key, value in pairs(Defaults) do Lighting[key] = value end
    end
end

function Fullbright:IsEnabled() return Enabled end
function Fullbright:GetState() return Enabled and "on" or "off" end
return Fullbright
