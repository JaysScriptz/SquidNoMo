local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RingShooter = { Enabled = false, LastShot = 0 }

local function isRingMode()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local gui = playerGui:FindFirstChild("MarblesGui", true) or playerGui:FindFirstChild("RingGui", true)
    if gui and gui.Enabled then
        return gui
    end
    
    local ring = Workspace:FindFirstChild("MarbleRing") or Workspace:FindFirstChild("Ring")
    if ring then
        return ring
    end
    return nil
end

function RingShooter:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isRingMode() then return end
            
            if tick() - self.LastShot < 1.5 then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            local targetMarble = nil
            local ring = Workspace:FindFirstChild("MarbleRing") or Workspace:FindFirstChild("Ring")
            
            if ring then
                for _, obj in ipairs(ring:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():match("marble") or obj.Name:lower():match("ball")) then
                        targetMarble = obj
                        break
                    end
                end
            end
            
            if targetMarble then
                self.LastShot = tick()
                
                -- Calculate distance from player to target marble to dynamically scale power
                local distance = (targetMarble.Position - hrp.Position).Magnitude
                
                -- Scale power based on distance (e.g., minimum power of 30, scaling higher for further targets, capped at 100)
                local calculatedPower = math.clamp(distance * 3.5, 30, 100)
                
                local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
                if eventsFolder then
                    for _, remote in ipairs(eventsFolder:GetChildren()) do
                        if remote:IsA("RemoteEvent") and (remote.Name:lower():match("shoot") or remote.Name:lower():match("throw") or remote.Name:lower():match("marble") or remote.Name:lower():match("hit")) then
                            pcall(function()
                                -- Fire with target position and dynamically scaled power based on distance
                                remote:FireServer(targetMarble.Position, calculatedPower)
                            end)
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Marbles RingShooter (Distance-Based Power) Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Marbles RingShooter Disabled.")
    end
end

return RingShooter
