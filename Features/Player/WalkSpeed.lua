local WalkSpeed = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local DefaultSpeed = 16
local CurrentSpeed = DefaultSpeed
local PreferredSpeed = 32

local function Apply()
    local character = LocalPlayer and LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = CurrentSpeed
    end
end

function WalkSpeed:Set(value)
    CurrentSpeed = math.clamp(tonumber(value) or DefaultSpeed, 8, 100)
    if CurrentSpeed ~= DefaultSpeed then
        PreferredSpeed = CurrentSpeed
    end
    Apply()
end

function WalkSpeed:Enable()
    self:Set(PreferredSpeed)
end

function WalkSpeed:Disable()
    self:Reset()
end

function WalkSpeed:Get()
    return CurrentSpeed
end

function WalkSpeed:Reset()
    CurrentSpeed = DefaultSpeed
    Apply()
end

function WalkSpeed:IsEnabled()
    return CurrentSpeed ~= DefaultSpeed
end

function WalkSpeed:GetState()
    return self:IsEnabled() and "on" or "off"
end

if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.25)
        Apply()
    end)
end

return WalkSpeed
