local JumpPower = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local DefaultJumpPower = 50
local CurrentJumpPower = DefaultJumpPower
local PreferredJumpPower = 80

local function Apply()
    local character = LocalPlayer and LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = CurrentJumpPower
    end
end

function JumpPower:Set(value)
    CurrentJumpPower = math.clamp(tonumber(value) or DefaultJumpPower, 25, 200)
    if CurrentJumpPower ~= DefaultJumpPower then
        PreferredJumpPower = CurrentJumpPower
    end
    Apply()
end

function JumpPower:Enable()
    self:Set(PreferredJumpPower)
end

function JumpPower:Disable()
    self:Reset()
end

function JumpPower:Get()
    return CurrentJumpPower
end

function JumpPower:Reset()
    CurrentJumpPower = DefaultJumpPower
    Apply()
end

function JumpPower:IsEnabled()
    return CurrentJumpPower ~= DefaultJumpPower
end

function JumpPower:GetState()
    return self:IsEnabled() and "on" or "off"
end

if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.25)
        Apply()
    end)
end

return JumpPower
