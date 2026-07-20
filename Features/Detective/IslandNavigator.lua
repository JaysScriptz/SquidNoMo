local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local IslandNavigator = { Active = false }

function IslandNavigator:NavigateTo(targetPosition)
    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 5})
    local success, errMsg = pcall(function() path:ComputeAsync(char.HumanoidRootPart.Position, targetPosition) end)
    
    if success and path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            if not self.Active then break end
            char.Humanoid:MoveTo(waypoint.Position)
            char.Humanoid.MoveToFinished:Wait()
        end
    end
end

return IslandNavigator
