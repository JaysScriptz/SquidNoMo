local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CoffinCollector = { Enabled = false, ActionCooldown = 0, MaxRange = 40 }

local function interactWithTarget(targetPart)
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    else
        local cd = targetPart:FindFirstChildOfClass("ClickDetector")
        if cd then fireclickdetector(cd) end
    end
end

function CoffinCollector:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.ActionCooldown < 1.0 then return end
            
            local char = Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- If holding something already, don't grab more
            if char:FindFirstChildOfClass("Tool") then return end
            
            local coffinFolder = Workspace:FindFirstChild("Coffins") or Workspace:FindFirstChild("Bodies")
            if not coffinFolder then return end
            
            for _, obj in ipairs(coffinFolder:GetChildren()) do
                local part = obj:IsA("Model") and obj.PrimaryPart or obj
                if part and (part.Position - char.HumanoidRootPart.Position).Magnitude <= self.MaxRange then
                    -- Only grab if it has a prompt (ready to be picked up)
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        char.Humanoid:MoveTo(part.Position)
                        if (part.Position - char.HumanoidRootPart.Position).Magnitude <= 8 then
                            interactWithTarget(prompt.Parent)
                            self.ActionCooldown = tick()
                        end
                        return
                    end
                end
            end
        end)
        print("[SquidNoMo]: CoffinCollector Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
    end
end

return CoffinCollector
