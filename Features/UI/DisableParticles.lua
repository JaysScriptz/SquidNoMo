local DisableParticles = {}
local Workspace = game:GetService("Workspace")

local Enabled = false
local States = {}
local Connection = nil

local function supported(object)
    return object:IsA("ParticleEmitter")
        or object:IsA("Trail")
        or object:IsA("Beam")
        or object:IsA("Fire")
        or object:IsA("Smoke")
        or object:IsA("Sparkles")
end

local function apply(object)
    if not supported(object) then return end
    if States[object] == nil then
        States[object] = object.Enabled
    end
    object.Enabled = false
end

function DisableParticles:Enable()
    if Enabled then return end
    Enabled = true
    for _, object in ipairs(Workspace:GetDescendants()) do
        apply(object)
    end
    Connection = Workspace.DescendantAdded:Connect(function(object)
        if Enabled then apply(object) end
    end)
end

function DisableParticles:Disable()
    Enabled = false
    if Connection then Connection:Disconnect() Connection = nil end
    for object, state in pairs(States) do
        if object and object.Parent then
            object.Enabled = state
        end
    end
    table.clear(States)
end

function DisableParticles:IsEnabled() return Enabled end
function DisableParticles:GetState() return Enabled and "on" or "off" end

return DisableParticles
