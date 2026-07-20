local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local AutoMove = {
    Enabled = false,
    Thread = nil,
    ValidDollNames = {"Doll", "RedLightDoll", "Killer", "SquidDoll", "Mugunghwa"},
}

-- Detects if Red Light is active
local function isRedLight()
    local status = workspace:FindFirstChild("GameStatus", true) or workspace:FindFirstChild("Status", true)
    if status then
        local val = tostring(status.Value):lower()
        return val:match("red") or val == "stop"
    end
    return false
end

-- Locates the Doll dynamically
local function getDoll()
    for _, name in ipairs(AutoMove.ValidDollNames) do
        local found = workspace:FindFirstChild(name, true)
        if found and found:FindFirstChild("HumanoidRootPart") then return found end
    end
    return nil
end

function AutoMove:Toggle(state)
    self.Enabled = state
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    if state then
        self.Thread = task.spawn(function()
            local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 5})
            
            while self.Enabled do
                local doll = getDoll()
                
                if doll and not isRedLight() then
                    -- Target the doll's position, but offset by 10 studs forward to "pass" it
                    local goal = doll.HumanoidRootPart.Position + (doll.HumanoidRootPart.CFrame.LookVector * 10)
                    
                    local success, _ = pcall(function()
                        path:ComputeAsync(hrp.Position, goal)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        if waypoints[2] then
                            humanoid:MoveTo(waypoints[2].Position)
                        end
                    end
                else
                    -- Stop moving if Red Light OR Doll is missing
                    humanoid:MoveTo(hrp.Position)
                end
                task.wait(0.2)
            end
        end)
        print("[SquidNoMo]: AutoMove (Doll-Tracking) Enabled.")
    else
        if self.Thread then task.cancel(self.Thread) end
        humanoid:MoveTo(hrp.Position)
        print("[SquidNoMo]: AutoMove Disabled.")
    end
end

return AutoMove
