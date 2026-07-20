local RemoveBlur = {}
local Lighting = game:GetService("Lighting")
local Enabled = false
local States = {}
local Connection = nil

local function disable(effect)
    if effect:IsA("BlurEffect") then
        if States[effect] == nil then States[effect] = effect.Enabled end
        effect.Enabled = false
    end
end

function RemoveBlur:Enable()
    if Enabled then return end
    Enabled = true
    for _, child in ipairs(Lighting:GetChildren()) do disable(child) end
    Connection = Lighting.ChildAdded:Connect(function(child)
        if Enabled then disable(child) end
    end)
end

function RemoveBlur:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    for effect, state in pairs(States) do
        if effect and effect.Parent then effect.Enabled = state end
    end
    table.clear(States)
end

function RemoveBlur:IsEnabled() return Enabled end
function RemoveBlur:GetState() return Enabled and "on" or "off" end
return RemoveBlur
