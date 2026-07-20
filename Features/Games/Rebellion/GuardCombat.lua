local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local GuardCombat = { Enabled = false, LastAttack = 0 }

function GuardCombat:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.LastAttack < 0.25 then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            -- Detect guards or security NPCs in the workspace
            local guardsFolder = Workspace:FindFirstChild("Guards") or Workspace:FindFirstChild("NPCs") or Workspace:FindFirstChild("Enemies")
            local nearestGuard = nil
            local shortestDist = 35
            
            if guardsFolder then
                for _, guard in ipairs(guardsFolder:GetChildren()) do
                    local guardRoot = guard:FindFirstChild("HumanoidRootPart") or guard:FindFirstChild("Head") or (guard:IsA("Model") and guard.PrimaryPart)
                    if guardRoot then
                        local dist = (guardRoot.Position - hrp.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearestGuard = guardRoot
                        end
                    end
                end
            end
            
            if nearestGuard then
                self.LastAttack = tick()
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(nearestGuard.Position.X, hrp.Position.Y, nearestGuard.Position.Z))
                
                local tool = character:FindFirstChildOfClass("Tool") or Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent == Players.LocalPlayer.Backpack then
                        tool.Parent = character
                    end
                    pcall(function() tool:Activate() end)
                end
            end
        end)
        print("[SquidNoMo]: Rebellion GuardCombat Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Rebellion GuardCombat Disabled.")
    end
end

return GuardCombat
