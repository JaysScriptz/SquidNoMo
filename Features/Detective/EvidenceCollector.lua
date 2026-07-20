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


local EvidenceCollector = { Enabled = false }

function EvidenceCollector:Toggle(state)
    self.Enabled = state
    task.spawn(function()
        while self.Enabled do
            local char = Players.LocalPlayer.Character
            local evidence = Workspace:FindFirstChild("Evidence", true) or Workspace:FindFirstChild("Clue", true)
            
            if evidence then
                Navigator.Active = true
                Navigator:NavigateTo(evidence:GetPivot().Position)
                
                local prompt = evidence:FindFirstChildOfClass("ProximityPrompt", true)
                if prompt and (evidence:GetPivot().Position - char.HumanoidRootPart.Position).Magnitude < 10 then
                    fireproximityprompt(prompt)
                    task.wait(2) -- Allow time for search animation
                end
            end
            task.wait(1)
        end
    end)
end

return EvidenceCollector
