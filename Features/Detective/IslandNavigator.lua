local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Walks the detective from the boat/start area to the nearest evidence target.
-- This module uses Humanoid:MoveTo and PathfindingService only; it does not teleport.
local IslandNavigator = { Enabled = false, NavigationTask = nil }

local EVIDENCE_PATTERNS = {
    "evidence",
    "clue",
    "file",
    "keycard",
}

local function positionOf(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then
        return instance.Position
    end
    if instance:IsA("Model") then
        return instance:GetPivot().Position
    end
    return nil
end

local function isEvidence(instance)
    if not (instance:IsA("BasePart") or instance:IsA("Model")) then
        return false
    end

    local lowerName = instance.Name:lower()
    for _, pattern in ipairs(EVIDENCE_PATTERNS) do
        if lowerName:find(pattern, 1, true) then
            return true
        end
    end
    return false
end

function IslandNavigator:FindNearestEvidence(origin)
    local nearestPosition
    local nearestDistance = math.huge

    for _, instance in ipairs(Workspace:GetDescendants()) do
        if isEvidence(instance) then
            local targetPosition = positionOf(instance)
            if targetPosition then
                local distance = (targetPosition - origin).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPosition = targetPosition
                end
            end
        end
    end

    return nearestPosition
end

function IslandNavigator:NavigateTo(target)
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or not target then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4,
    })

    local success = pcall(function()
        path:ComputeAsync(root.Position, target)
    end)
    if not success or path.Status ~= Enum.PathStatus.Success then
        return false
    end

    for _, waypoint in ipairs(path:GetWaypoints()) do
        if not self.Enabled then return false end
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(waypoint.Position)
        if not humanoid.MoveToFinished:Wait() then
            return false
        end
    end

    return true
end

function IslandNavigator:Toggle(state)
    self.Enabled = state == true

    if not self.Enabled then
        if self.NavigationTask then
            task.cancel(self.NavigationTask)
            self.NavigationTask = nil
        end
        return
    end

    if self.NavigationTask then
        task.cancel(self.NavigationTask)
    end

    self.NavigationTask = task.spawn(function()
        local player = Players.LocalPlayer
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local target = root and self:FindNearestEvidence(root.Position)

        if target and self.Enabled then
            self:NavigateTo(target)
        else
            warn("[SquidNoMo] No detective evidence target was found.")
        end

        self.Enabled = false
        self.NavigationTask = nil
    end)
end

function IslandNavigator:IsEnabled()
    return self.Enabled
end

return IslandNavigator
