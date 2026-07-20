local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local AutoSwing = { Enabled = false, LastAttack = 0 }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("HideAndSeekGui", true) or playerGui:FindFirstChild("HnSGui", true)
    return gui and gui.Enabled
end

-- Strictly check if the player is assigned as a Seeker (has a knife equipped or in backpack)
local function isSeeker()
    local player = Players.LocalPlayer
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    local hasKnifeInChar = character and character:FindFirstChild("Knife")
    local hasKnifeInBackpack = backpack and backpack:FindFirstChild("Knife")
    
    return hasKnifeInChar or hasKnifeInBackpack
end

function AutoSwing:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            -- Guard clause: Stop immediately if not playing as a Seeker with a knife
            if not isSeeker() then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local myRoot = character.HumanoidRootPart
            
            -- Scan for nearby targets to attack
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = otherPlayer.Character.HumanoidRootPart
                    local distance = (targetRoot.Position - myRoot.Position).Magnitude
                    
                    -- If target is within range, continuously swing until health is depleted
                    if distance <= 14 then
                        local currentTime = tick()
                        if currentTime - self.LastAttack >= 0.25 then
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                            self.LastAttack = currentTime
                        end
                        break
                    end
                end
            end
        end)
        print("[SquidNoMo]: AutoSwing Seeker Module Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: AutoSwing Disabled.")
    end
end

return AutoSwing
