local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local InstantGrabPole = { Enabled = false }

function InstantGrabPole:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            
            -- Scan workspace for poles, knives, or weapons available to pick up
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Tool") or (obj:IsA("Model") and (obj.Name:lower():match("pole") or obj.Name:lower():match("weapon") or obj.Name:lower():match("knife"))) then
                    local targetPart = obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if targetPart then
                        local dist = (targetPart.Position - hrp.Position).Magnitude
                        if dist < 35 then
                            -- Pull object directly to player hand/root part
                            targetPart.CFrame = hrp.CFrame
                            
                            -- Fire proximity prompt if available
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                            if prompt then
                                pcall(function()
                                    fireproximityprompt(prompt)
                                end)
                            end
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: SkySquid InstantGrabPole Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: SkySquid InstantGrabPole Disabled.")
    end
end

return InstantGrabPole
