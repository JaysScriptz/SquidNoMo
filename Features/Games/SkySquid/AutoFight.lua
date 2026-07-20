local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AutoFight = { Enabled = false }

function AutoFight:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local myPos = character.HumanoidRootPart.Position
            local tool = character:FindFirstChildOfClass("Tool")
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local otherHRP = otherPlayer.Character.HumanoidRootPart
                    if (otherHRP.Position - myPos).Magnitude < 8 then
                        -- Activate tool/weapon attack if equipped
                        if tool and tool:FindFirstChild("Activate") then
                            pcall(function() tool:Activate() end)
                        elseif tool and tool:FindFirstChild("Handle") then
                            -- Simulate mouse click / tool activation event
                            pcall(function()
                                local clickRemote = tool:FindFirstChild("CombatEvent") or tool:FindFirstChild("Attack")
                                if clickRemote and clickRemote:IsA("RemoteEvent") then
                                    clickRemote:FireServer()
                                end
                            end)
                        end
                        break
                    end
                end
            end
        end)
        print("[SquidNoMo]: SkySquid AutoFight Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: SkySquid AutoFight Disabled.")
    end
end

return AutoFight
