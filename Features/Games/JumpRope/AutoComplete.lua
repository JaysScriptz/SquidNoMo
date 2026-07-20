local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local AutoComplete = { Enabled = false, Path = nil, Waypoints = {}, CurrentWaypointIndex = 1, LastCompute = 0 }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("JumpRopeGui", true) or playerGui:FindFirstChild("JpRopeGui", true)
    return gui and gui.Enabled
end

function AutoComplete:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character.HumanoidRootPart
            
            -- Locate target finish line or safety platform
            local exitZone = workspace:FindFirstChild("JumpRopeExit") or workspace:FindFirstChild("FinishLine") or workspace:FindFirstChild("EndZone")
            if not exitZone then return end
            
            local targetPos = exitZone.Position
            local currentTime = tick()
            
            -- Recompute path every 2 seconds to dynamically track target position
            if currentTime - self.LastCompute > 2 then
                self.LastCompute = currentTime
                self.Path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true
                })
                
                local success, err = pcall(function()
                    self.Path:ComputeAsync(rootPart.Position, targetPos)
                end)
                
                if success and self.Path.Status == Enum.PathStatus.Success then
                    self.Waypoints = self.Path:GetWaypoints()
                    self.CurrentWaypointIndex = 2 -- Skip first point (current position)
                end
            end
            
            -- Walk along path waypoints automatically using auto-tracking
            if self.Waypoints and self.CurrentWaypointIndex <= #self.Waypoints then
                local waypoint = self.Waypoints[self.CurrentWaypointIndex]
                humanoid:MoveTo(waypoint.Position)
                
                -- Jump if path waypoint requires jumping
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                
                -- Progress to next waypoint when close enough
                if (rootPart.Position - waypoint.Position).Magnitude < 4 then
                    self.CurrentWaypointIndex = self.CurrentWaypointIndex + 1
                end
            end
        end)
        print("[SquidNoMo]: JumpRope AutoComplete (Pathfinder) Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):MoveTo(character.HumanoidRootPart.Position)
        end
        print("[SquidNoMo]: JumpRope AutoComplete Disabled.")
    end
end

return AutoComplete
