local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")

local EvidenceCollector = { Enabled = false, Worker = nil }

local function getCharacter()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function getPosition(instance)
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Model") then return instance:GetPivot().Position end
    return nil
end

local function findNearestEvidence(origin)
    local best, bestDistance = nil, math.huge
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("BasePart") or instance:IsA("Model") then
            local name = instance.Name:lower()
            if name:find("evidence", 1, true) or name:find("clue", 1, true) then
                local position = getPosition(instance)
                if position then
                    local distance = (position - origin).Magnitude
                    if distance < bestDistance then
                        best, bestDistance = instance, distance
                    end
                end
            end
        end
    end
    return best
end

function EvidenceCollector:NavigateTo(targetPosition)
    local _, humanoid, root = getCharacter()
    if not humanoid or not root or not targetPosition then return false end
    local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 5, AgentCanJump = true})
    local ok = pcall(path.ComputeAsync, path, root.Position, targetPosition)
    if not ok or path.Status ~= Enum.PathStatus.Success then return false end
    for _, waypoint in ipairs(path:GetWaypoints()) do
        if not self.Enabled then return false end
        if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
        humanoid:MoveTo(waypoint.Position)
        if not humanoid.MoveToFinished:Wait() then return false end
    end
    return true
end

function EvidenceCollector:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state
    if self.Worker then task.cancel(self.Worker); self.Worker = nil end
    if not state then return end

    self.Worker = task.spawn(function()
        while self.Enabled do
            local _, _, root = getCharacter()
            local evidence = root and findNearestEvidence(root.Position)
            local target = evidence and getPosition(evidence)
            if target and self:NavigateTo(target) and self.Enabled then
                local _, _, currentRoot = getCharacter()
                local prompt = evidence:FindFirstChildWhichIsA("ProximityPrompt", true)
                if currentRoot and prompt and (target - currentRoot.Position).Magnitude <= 12
                    and type(fireproximityprompt) == "function" then
                    fireproximityprompt(prompt)
                    task.wait(2)
                end
            end
            task.wait(1)
        end
        self.Worker = nil
    end)
end

function EvidenceCollector:IsEnabled()
    return self.Enabled
end

return EvidenceCollector
