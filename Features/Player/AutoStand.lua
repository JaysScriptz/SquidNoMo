local AutoStand = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Enabled = false
local Connection = nil

local function getHumanoid()
    local character = LocalPlayer and LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

function AutoStand:Enable()
    if Enabled then return end
    Enabled = true
    Connection = RunService.Heartbeat:Connect(function()
        local humanoid = getHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end
        if humanoid.Sit or humanoid:GetState() == Enum.HumanoidStateType.Seated then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

function AutoStand:Disable()
    Enabled = false
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

function AutoStand:IsEnabled()
    return Enabled
end

function AutoStand:GetState()
    return Enabled and "on" or "off"
end

return AutoStand
