local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CoffinDisposer = { Enabled = false, ActionCooldown = 0, MaxRange = 60 }

local function interactWithTarget(targetPart)
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    else
        local cd = targetPart:FindFirstChildOfClass("ClickDetector")
        if cd then fireclickdetector(cd) end
    end
end

function CoffinDisposer:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.ActionCooldown < 1.0 then return end
            
            local char = Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Only run if holding a coffin/tool
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or not (tool.Name:lower():match("coffin") or tool.Name:lower():match("body")) then return end
            
            local furnaceFolder = Workspace:FindFirstChild("Furnaces") or Workspace:FindFirstChild("Incinerators")
            if not furnaceFolder then return end
            
            for _, obj in ipairs(furnaceFolder:GetChildren()) do
                local part = obj:IsA("Model") and obj.PrimaryPart or obj
                if part and (part.Position - char.HumanoidRootPart.Position).Magnitude <= self.MaxRange then
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                    
                    -- Navigate to furnace
                    char.Humanoid:MoveTo(part.Position)
                    
                    -- Deposit when close
                    if (part.Position - char.HumanoidRootPart.Position).Magnitude <= 10 then
                        if prompt and prompt.Enabled then
                            interactWithTarget(prompt.Parent)
                            self.ActionCooldown = tick()
                        end
                    end
                    return
                end
            end
        end)
        print("[SquidNoMo]: CoffinDisposer Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
    end
end

return CoffinDisposer
