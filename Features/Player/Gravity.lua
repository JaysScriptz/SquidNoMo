local Gravity = {}
local Workspace = game:GetService("Workspace")

local DefaultGravity = Workspace.Gravity
local CurrentGravity = DefaultGravity
local PreferredGravity = math.clamp(math.floor(DefaultGravity * 0.62), 30, 300)

local function apply()
    Workspace.Gravity = CurrentGravity
end

function Gravity:Set(value)
    CurrentGravity = math.clamp(tonumber(value) or DefaultGravity, 20, 300)
    if math.abs(CurrentGravity - DefaultGravity) > 0.1 then
        PreferredGravity = CurrentGravity
    end
    apply()
end

function Gravity:Get()
    return CurrentGravity
end

function Gravity:Enable()
    self:Set(PreferredGravity)
end

function Gravity:Disable()
    CurrentGravity = DefaultGravity
    apply()
end

function Gravity:IsEnabled()
    return math.abs(CurrentGravity - DefaultGravity) > 0.1
end

function Gravity:GetState()
    return self:IsEnabled() and "on" or "off"
end

return Gravity
