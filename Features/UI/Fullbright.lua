local Fullbright = {}
local Lighting = game:GetService("Lighting")

local Enabled = false
local Defaults = nil
local Connections = {}

local function disconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(Connections)
end

local function apply()
    if not Enabled then return end
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
end

function Fullbright:Enable()
    if Enabled then return end
    Enabled = true
    Defaults = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }

    apply()
    for _, property in ipairs({"Brightness", "ClockTime", "Ambient", "OutdoorAmbient"}) do
        table.insert(Connections, Lighting:GetPropertyChangedSignal(property):Connect(apply))
    end
end

function Fullbright:Disable()
    Enabled = false
    disconnectAll()
    if Defaults then
        Lighting.Brightness = Defaults.Brightness
        Lighting.ClockTime = Defaults.ClockTime
        Lighting.Ambient = Defaults.Ambient
        Lighting.OutdoorAmbient = Defaults.OutdoorAmbient
    end
    Defaults = nil
end

function Fullbright:IsEnabled() return Enabled end
function Fullbright:GetState() return Enabled and "on" or "off" end

return Fullbright
