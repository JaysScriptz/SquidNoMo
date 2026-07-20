local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BrawlCombatAura = { Enabled = false, LastAttack = 0 }

function BrawlCombatAura:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.LastAttack < 0.25 then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            -- Find the nearest hostile player within engagement range
            local nearestTarget = nil
            local shortestDist = 20
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = player.Character.HumanoidRootPart
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearestTarget = targetHrp
                    end
                end
            end
            
            if nearestTarget then
                self.LastAttack = tick()
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(nearestTarget.Position.X, hrp.Position.Y, nearestTarget.Position.Z))
                
                local tool = character:FindFirstChildOfClass("Tool") or Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent == Players.LocalPlayer.Backpack then
                        tool.Parent = character
                    end
                    pcall(function() tool:Activate() end)
                end
            end
        end)
        print("[SquidNoMo]: BrawlCombatAura Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: BrawlCombatAura Disabled.")
    end
end

return BrawlCombatAura
