local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local HunterTracker = { Enabled = false }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("HideAndSeekGui", true) or playerGui:FindFirstChild("HnSGui", true)
    return gui and gui.Enabled
end

function HunterTracker:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local myPos = character.HumanoidRootPart.Position
            
            -- Seeker Target Scanner: Highlights or alerts when a Hider is within striking distance
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = otherPlayer.Character.HumanoidRootPart
                    local distance = (targetRoot.Position - myPos).Magnitude
                    
                    -- If a target hider is close by in the maze corridor
                    if distance <= 25 then
                        -- Ready for knife swing or backstab alignment check
                    end
                end
            end
        end)
        print("[SquidNoMo]: HunterTracker (Seeker Module) Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: HunterTracker Disabled.")
    end
end

return HunterTracker
