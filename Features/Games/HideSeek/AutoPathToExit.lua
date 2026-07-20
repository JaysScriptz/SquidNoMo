local AutoPathToExit = {
    Enabled = false,
    BaseSpeed = 16,       -- Standard Roblox walk speed
    MaxSafeSpeed = 35,    -- Maximum speed before anti-cheat usually flags you
}

function AutoPathToExit:Toggle(state, mapFolder)
    local localPlayer = game.Players.LocalPlayer
    local PathfindingService = game:GetService("PathfindingService")
    
    self.Enabled = state
    
    if state then
        if not mapFolder then 
            warn("[SquidNoMo]: Map folder not provided for Auto Path.")
            return 
        end

        task.spawn(function()
            while self.Enabled do
                task.wait(0.5) -- Scan interval
                
                local character = localPlayer.Character
                if not character then continue end
                
                local humanoid = character:FindFirstChild("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not humanoid or not hrp then continue end
                
                local hasKey = character:FindFirstChild("Key") or localPlayer.Backpack:FindFirstChild("Key")
                
                if hasKey then
                    -- 1. Find the exit door
                    local targetDoor = nil
                    for _, part in ipairs(mapFolder:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name:lower():match("exit") or part.Name:lower():match("door")) then
                            targetDoor = part
                            break
                        end
                    end
                    
                    if targetDoor then
                        -- 2. Create and compute the path
                        local path = PathfindingService:CreatePath({
                            AgentRadius = 2,
                            AgentHeight = 5,
                            AgentCanJump = true,
                            WaypointSpacing = 4,
                        })
                        
                        local success, _ = pcall(function()
                            path:ComputeAsync(hrp.Position, targetDoor.Position)
                        end)
                        
                        -- 3. Walk the path if successful
                        if success and path.Status == Enum.PathStatus.Success then
                            local waypoints = path:GetWaypoints()
                            
                            for i, waypoint in ipairs(waypoints) do
                                if not self.Enabled then break end
                                
                                -- Dynamically scale speed: Faster when far, slower when close
                                local distToTarget = (hrp.Position - targetDoor.Position).Magnitude
                                local dynamicSpeed = self.BaseSpeed + (distToTarget * 0.15)
                                humanoid.WalkSpeed = math.clamp(dynamicSpeed, self.BaseSpeed, self.MaxSafeSpeed)
                                
                                -- Handle jumping over obstacles
                                if waypoint.Action == Enum.PathWaypointAction.Jump then
                                    humanoid.Jump = true
                                end
                                
                                -- Move to the next node
                                humanoid:MoveTo(waypoint.Position)
                                
                                -- Wait until we reach the node (or timeout if stuck)
                                local timeOut = tick() + 2
                                repeat
                                    task.wait(0.05)
                                until (hrp.Position - waypoint.Position).Magnitude < 3 or tick() > timeOut or not self.Enabled
                            end
                            
                            -- Reset speed once we arrive
                            humanoid.WalkSpeed = self.BaseSpeed
                            
                            -- 4. Fire the exit prompt
                            if self.Enabled then
                                local prompt = targetDoor:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and (hrp.Position - targetDoor.Position).Magnitude < 10 then
                                    pcall(function() fireproximityprompt(prompt) end)
                                    self.Enabled = false -- Automatically toggle off after escaping
                                end
                            end
                        else
                            warn("[SquidNoMo]: Path blocked or computation failed. Retrying...")
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Auto-Path to Exit (Natural Pathfinding) Enabled.")
    else
        -- Clean up and reset speed if manually disabled mid-walk
        self.Enabled = false
        local character = localPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = self.BaseSpeed
        end
        print("[SquidNoMo]: Auto-Path to Exit Disabled.")
    end
end

return AutoPathToExit
