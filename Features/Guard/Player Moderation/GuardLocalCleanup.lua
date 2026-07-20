local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local GuardLocalCleanup = { Enabled = false, MaxRange = 80 }

local function getActiveGameType()
    for _, child in ipairs(Workspace:GetChildren()) do
        local name = child.Name:lower()
        if name:match("rlgl") or name:match("glass") or name:match("dalgona") or name:match("hide") or name:match("marbles") then
            return name
        end
    end
    return "unknown"
end

function GuardLocalCleanup:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local currentGame = getActiveGameType()
            if currentGame:match("rebellion") then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local hrp = character.HumanoidRootPart
            
            if not humanoid then return end
            
            local bodiesFolder = Workspace:FindFirstChild("Bodies") or Workspace:FindFirstChild("Coffins") or Workspace:FindFirstChild("Ragdolls")
            local nearestBody = nil
            local shortestDist = self.MaxRange
            
            if bodiesFolder then
                for _, body in ipairs(bodiesFolder:GetChildren()) do
                    local part = body:IsA("Model") and body.PrimaryPart or body:FindFirstChild("HumanoidRootPart") or body
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - hrp.Position).Magnitude
                        -- Strict distance check to ensure we aren't targeting a different room
                        if dist < shortestDist then
                            shortestDist = dist
                            nearestBody = part
                        end
                    end
                end
            end
            
            if nearestBody then
                -- Walk naturally, no CFrame teleports
                humanoid:MoveTo(nearestBody.Position)
            end
        end)
        print("[SquidNoMo]: GuardLocalCleanup Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: GuardLocalCleanup Disabled.")
    end
end

return GuardLocalCleanup
