local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local AutoPathToExit = { Enabled = false, BaseSpeed = 16, MaxSafeSpeed = 35, Worker = nil }

local function findExit()
    local best
    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("BasePart") then
            local name = object.Name:lower()
            if name:find("exit", 1, true) or name:find("escape", 1, true) then
                best = object
                if object:FindFirstChildWhichIsA("ProximityPrompt", true) then break end
            end
        end
    end
    return best
end

function AutoPathToExit:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state
    if self.Worker then task.cancel(self.Worker); self.Worker = nil end
    if not state then
        local character = Players.LocalPlayer and Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = self.BaseSpeed end
        return
    end

    self.Worker = task.spawn(function()
        while self.Enabled do
            local player = Players.LocalPlayer
            local character = player and player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local backpack = player and player:FindFirstChildOfClass("Backpack")
            local hasKey = character and character:FindFirstChild("Key") or (backpack and backpack:FindFirstChild("Key"))
            local targetDoor = hasKey and findExit()

            if humanoid and root and targetDoor then
                local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4})
                local success = pcall(path.ComputeAsync, path, root.Position, targetDoor.Position)
                if success and path.Status == Enum.PathStatus.Success then
                    for _, waypoint in ipairs(path:GetWaypoints()) do
                        if not self.Enabled then break end
                        humanoid.WalkSpeed = math.clamp(self.BaseSpeed + ((root.Position - targetDoor.Position).Magnitude * 0.15), self.BaseSpeed, self.MaxSafeSpeed)
                        if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
                        humanoid:MoveTo(waypoint.Position)
                        local timeout = os.clock() + 2
                        repeat task.wait(0.05) until not self.Enabled or (root.Position - waypoint.Position).Magnitude < 3 or os.clock() > timeout
                    end
                    humanoid.WalkSpeed = self.BaseSpeed
                    local prompt = targetDoor:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if self.Enabled and prompt and (root.Position - targetDoor.Position).Magnitude < 10 and type(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, prompt)
                        self.Enabled = false
                    end
                end
            end
            task.wait(0.5)
        end
        local character = Players.LocalPlayer and Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = self.BaseSpeed end
        self.Worker = nil
    end)
end

function AutoPathToExit:IsEnabled() return self.Enabled end
return AutoPathToExit
