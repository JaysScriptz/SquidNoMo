local DisableShadows = {}
local Lighting = game:GetService("Lighting")

local Enabled = false
local Default = nil
local Connection = nil

local function apply()
    if Enabled then
        Lighting.GlobalShadows = false
    end
end

function DisableShadows:Enable()
    if Enabled then return end
    Enabled = true
    Default = Lighting.GlobalShadows
    apply()
    Connection = Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(apply)
end

function DisableShadows:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    if Default ~= nil then Lighting.GlobalShadows = Default end
    Default = nil
end

function DisableShadows:IsEnabled() return Enabled end
function DisableShadows:GetState() return Enabled and "on" or "off" end

return DisableShadows
