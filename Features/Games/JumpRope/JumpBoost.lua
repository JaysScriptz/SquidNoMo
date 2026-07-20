local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local JumpPowerBoost = { Enabled = false, OriginalJumpPower = 50 }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("JumpRopeGui", true) or playerGui:FindFirstChild("JpRopeGui", true)
    return gui and gui.Enabled
end

function JumpPowerBoost:Toggle(state)
    self.Enabled = state
    local player = Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if state then
        if humanoid then
            self.OriginalJumpPower = humanoid.JumpPower
            humanoid.JumpPower = 75 -- Elevated jump height buffer
        end
        
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local currentHumanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if currentHumanoid and currentHumanoid.JumpPower ~= 75 then
                currentHumanoid.JumpPower = 75
            end
        end)
        print("[SquidNoMo]: JumpRope JumpPowerBoost Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        if humanoid then
            humanoid.JumpPower = self.OriginalJumpPower
        end
        print("[SquidNoMo]: JumpRope JumpPowerBoost Disabled.")
    end
end

return JumpPowerBoost
