local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")

local Navigator = { Active = true }
function Navigator:NavigateTo(targetPosition)
    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
    local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 5})
    local ok = pcall(function() path:ComputeAsync(char.HumanoidRootPart.Position, targetPosition) end)
    if ok and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not self.Active then break end
            char:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
            char:FindFirstChildOfClass("Humanoid").MoveToFinished:Wait()
        end
    end
end


local BoatDepositor = { Enabled = false }

function BoatDepositor:Toggle(state)
    self.Enabled = state
    task.spawn(function()
        while self.Enabled do
            local char = Players.LocalPlayer.Character
            -- Check if holding evidence tool
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and (tool.Name:lower():match("evidence") or tool.Name:lower():match("clue")) then
                local boat = Workspace:FindFirstChild("Boat", true) or Workspace:FindFirstChild("Escape", true)
                if boat then
                    Navigator:NavigateTo(boat:GetPivot().Position)
                    -- Trigger deposit interaction
                    local prompt = boat:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                end
            end
            task.wait(2)
        end
    end)
end

return BoatDepositor
