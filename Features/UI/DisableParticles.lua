local DisableParticles = {}
local Workspace = game:GetService("Workspace")

local Enabled = false
local States = setmetatable({}, {__mode = "k"})
local Connection = nil
local Generation = 0

local function supported(object)
    return object:IsA("ParticleEmitter")
        or object:IsA("Trail")
        or object:IsA("Beam")
        or object:IsA("Fire")
        or object:IsA("Smoke")
        or object:IsA("Sparkles")
end

local function apply(object)
    if not object or not supported(object) then return end
    if States[object] == nil then States[object] = object.Enabled end
    if object.Enabled then object.Enabled = false end
end

function DisableParticles:Enable()
    if Enabled then return end
    Enabled = true
    Generation = Generation + 1
    local generation = Generation

    Connection = Workspace.DescendantAdded:Connect(function(object)
        if Enabled and generation == Generation then apply(object) end
    end)

    -- Cooperative initial pass: disabling effects must not freeze a map-heavy
    -- mobile client for a frame.
    task.spawn(function()
        local queue = Workspace:GetChildren()
        local cursor = 1
        while Enabled and generation == Generation and cursor <= #queue do
            local object = queue[cursor]
            cursor = cursor + 1
            if object and object.Parent then
                apply(object)
                for _, child in ipairs(object:GetChildren()) do table.insert(queue, child) end
            end
            if cursor % 240 == 0 then task.wait() end
        end
    end)
end

function DisableParticles:Disable()
    Enabled = false
    Generation = Generation + 1
    if Connection then Connection:Disconnect() Connection = nil end
    for object, state in pairs(States) do
        if object and object.Parent then pcall(function() object.Enabled = state end) end
    end
    table.clear(States)
end

function DisableParticles:IsEnabled() return Enabled end
function DisableParticles:GetState() return Enabled and "on" or "off" end

return DisableParticles
