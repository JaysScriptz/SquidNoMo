local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")

local BoatDepositor = { Enabled = false, Worker = nil }

local function getCharacter()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return player, character, humanoid, root
end

local function getPosition(instance)
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Model") then return instance:GetPivot().Position end
    return nil
end

function BoatDepositor:NavigateTo(targetPosition)
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root or not targetPosition then return false end

    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 4,
    })
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

function BoatDepositor:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state

    if self.Worker then
        task.cancel(self.Worker)
        self.Worker = nil
    end
    if not state then return end

    self.Worker = task.spawn(function()
        while self.Enabled do
            local _, character = getCharacter()
            local tool = character and character:FindFirstChildOfClass("Tool")
            if tool then
                local name = tool.Name:lower()
                if name:find("evidence", 1, true) or name:find("clue", 1, true) then
                    local boat = Workspace:FindFirstChild("Boat", true) or Workspace:FindFirstChild("Escape", true)
                    local target = boat and getPosition(boat)
                    if target and self:NavigateTo(target) and self.Enabled then
                        local prompt = boat:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and type(fireproximityprompt) == "function" then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
            task.wait(2)
        end
        self.Worker = nil
    end)
end

function BoatDepositor:IsEnabled()
    return self.Enabled
end

return BoatDepositor
