local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AntiFall = { Enabled = false, LastSafePosition = nil }

function AntiFall:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            -- Update safe position while standing on solid platforms (above death thresholds)
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air and hrp.Position.Y > 10 then
                self.LastSafePosition = hrp.CFrame
            -- If falling into the abyss below platforms, snap back to safety
            elseif self.LastSafePosition and hrp.Position.Y < -5 then
                hrp.CFrame = self.LastSafePosition
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
        print("[SquidNoMo]: SkySquid AntiFall Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: SkySquid AntiFall Disabled.")
    end
end

return AntiFall
