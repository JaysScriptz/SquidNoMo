local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SquidGamePush = { Enabled = false, LastPush = 0 }

function SquidGamePush:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.LastPush < 0.25 then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            -- Find nearest remaining contestant in the final field
            local targetPlayer = nil
            local closestDist = 12
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = player.Character.HumanoidRootPart
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetPlayer = targetHrp
                    end
                end
            end
            
            if targetPlayer then
                self.LastPush = tick()
                -- Rotate character toward enemy and execute push/shove action
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPlayer.Position.X, hrp.Position.Y, targetPlayer.Position.Z))
                
                local pushTool = character:FindFirstChildOfClass("Tool") or Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if pushTool then
                    if pushTool.Parent == Players.LocalPlayer.Backpack then
                        pushTool.Parent = character
                    end
                    pcall(function() pushTool:Activate() end)
                end
            end
        end)
        print("[SquidNoMo]: SquidGame Push Module Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: SquidGame Push Module Disabled.")
    end
end

return SquidGamePush
