local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoPush = { Enabled = false, Cooldown = 0 }

function AutoPush:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.Cooldown < 0.8 then return end -- Prevent spam throttling
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local myPos = character.HumanoidRootPart.Position
            
            -- Find closest rival player on the platform
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local otherHRP = otherPlayer.Character.HumanoidRootPart
                    local dist = (otherHRP.Position - myPos).Magnitude
                    
                    if dist < 6 then -- Close proximity check for melee/push
                        self.Cooldown = tick()
                        
                        -- Look for combat or push remotes in ReplicatedStorage
                        local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
                        if eventsFolder then
                            for _, remote in ipairs(eventsFolder:GetChildren()) do
                                if remote:IsA("RemoteEvent") and (remote.Name:lower():match("push") or remote.Name:lower():match("shove") or remote.Name:lower():match("hit")) then
                                    pcall(function()
                                        remote:FireServer(otherPlayer)
                                    end)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end)
        print("[SquidNoMo]: SkySquid AutoPush Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: SkySquid AutoPush Disabled.")
    end
end

return AutoPush
