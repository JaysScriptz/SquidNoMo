local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local FrontmanNavigator = { Enabled = false }

function FrontmanNavigator:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Locate objective endpoint (Frontman room / door / console)
            local objective = Workspace:FindFirstChild("FrontmanRoom") or Workspace:FindFirstChild("ObjectiveDoor") or Workspace:FindFirstChild("ControlRoom")
            if objective then
                local targetPos = objective.Position or (objective:IsA("Model") and objective.WorldPivot.Position)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and targetPos then
                    humanoid:MoveTo(targetPos)
                end
            end
        end)
        print("[SquidNoMo]: Rebellion FrontmanNavigator Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Rebellion FrontmanNavigator Disabled.")
    end
end

return FrontmanNavigator
