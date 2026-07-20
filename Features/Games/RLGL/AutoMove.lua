local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local AutoMove = {
    Enabled = false,
    Thread = nil,
}

-- CONFIG: Replace this with the position of the finish line in your game
local FINISH_LINE_POSITION = Vector3.new(0, 5, 500) 

local function isRedLight()
    local status = workspace:FindFirstChild("GameStatus", true) or workspace:FindFirstChild("Status", true)
    if status then
        local val = tostring(status.Value):lower()
        return val:match("red") or val == "stop"
    end
    return false
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
                if not isRedLight() then
                    -- Compute path to goal
                    local success, errorMessage = pcall(function()
                        path:ComputeAsync(hrp.Position, FINISH_LINE_POSITION)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        -- Move to the next waypoint
                        if waypoints[2] then
                            humanoid:MoveTo(waypoints[2].Position)
                        end
                    end
                else
                    -- Stop moving immediately on Red Light
                    humanoid:MoveTo(hrp.Position)
                end
                task.wait(0.2) -- Path update frequency
            end
        end)
        print("[SquidNoMo]: AutoMove Enabled.")
    else
        if self.Thread then task.cancel(self.Thread) end
        humanoid:MoveTo(hrp.Position) -- Stop character
        print("[SquidNoMo]: AutoMove Disabled.")
    end
end

return AutoMove
