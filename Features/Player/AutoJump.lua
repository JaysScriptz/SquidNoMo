local AutoJump = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local Connection = nil
local Elapsed = 0

local function getHumanoid()
    local character = LocalPlayer and LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

function AutoJump:Enable()
    if Enabled then return end
    Enabled = true
    Elapsed = 0
    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        Elapsed = Elapsed + deltaTime
        if Elapsed < 0.18 then return end
        Elapsed = 0

        local humanoid = getHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end
        if humanoid.MoveDirection.Magnitude <= 0.05 then return end
        if humanoid.Sit or humanoid.FloorMaterial == Enum.Material.Air then return end

        humanoid.Jump = true
    end)
end

function AutoJump:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

function AutoJump:IsEnabled()
    return Enabled
end

function AutoJump:GetState()
    return Enabled and "on" or "off"
end

return AutoJump
