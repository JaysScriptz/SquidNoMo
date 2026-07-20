local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

local AutoWalk = { Enabled = false }

local function getSafeTiles()
    local safe = {}
    local glassBridge = workspace:FindFirstChild("GlassBridge") or workspace:FindFirstChild("GlassSteppingStones")
    if not glassBridge then return safe end
    
    for _, part in ipairs(glassBridge:GetDescendants()) do
        if part:IsA("BasePart") and (part:GetAttribute("IsSafe") == true) then
            table.insert(safe, part)
        end
    end
    return safe
end

function AutoWalk:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            local char = Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = char.HumanoidRootPart
            local safeTiles = getSafeTiles()
            
            -- Find the nearest safe tile in front of the player
            local targetTile = nil
            local closestDist = math.huge
            
            for _, tile in ipairs(safeTiles) do
                local dist = (tile.Position - hrp.Position).Magnitude
                -- Only target tiles ahead of us (positive Z/X relative to bridge direction)
                if dist < 25 and dist > 5 and dist < closestDist then
                    closestDist = dist
                    targetTile = tile
                end
            end
            
            if targetTile then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:MoveTo(targetTile.Position + Vector3.new(0, 3, 0))
                    -- Auto-jump to ensure we clear gaps
                    if (targetTile.Position - hrp.Position).Magnitude < 10 then
                        hum.Jump = true
                    end
                end
            end
        end)
        print("[SquidNoMo]: GlassBridge AutoWalk Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: GlassBridge AutoWalk Disabled.")
    end
end

return AutoWalk
