local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BrawlEvasion = { Enabled = false }

function BrawlEvasion:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp then
                -- If health drops below 35%, automatically create distance from enemies
                if humanoid.Health < (humanoid.MaxHealth * 0.35) then
                    hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * -35 + Vector3.new(0, 5, 0)
                end
            end
        end)
        print("[SquidNoMo]: BrawlEvasion Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: BrawlEvasion Disabled.")
    end
end

return BrawlEvasion
