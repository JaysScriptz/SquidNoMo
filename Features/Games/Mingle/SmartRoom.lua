local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MingleSmartMover = { Enabled = false, LastShift = 0 }

local function getRequiredCount()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local gui = playerGui:FindFirstChild("MingleGui", true) or playerGui:FindFirstChild("CarouselGui", true)
    if gui and gui.Enabled then
        local countLabel = gui:FindFirstChild("RequiredCount", true) or gui:FindFirstChild("NumberLabel", true) or gui:FindFirstChild("TargetText", true)
        if countLabel and countLabel:IsA("TextLabel") then
            local num = tonumber(countLabel.Text:match("%d+"))
            if num then return num end
        end
    end
    return nil
end

function MingleSmartMover:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            if tick() - self.LastShift < 1.5 then return end
            
            local requiredCount = getRequiredCount()
            if not requiredCount then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            local doorsFolder = Workspace:FindFirstChild("MingleRooms") or Workspace:FindFirstChild("Doors") or Workspace:FindFirstChild("Rooms")
            if not doorsFolder then return end
            
            -- Evaluate all rooms to find one matching the required group quota with available slot space
            for _, door in ipairs(doorsFolder:GetChildren()) do
                local doorPart = door:IsA("Model") and door.PrimaryPart or door
                if doorPart then
                    local isTargetType = door.Name:match(tostring(requiredCount)) or (door:FindFirstChild("Capacity") and door.Capacity.Value == requiredCount)
                    
                    if isTargetType then
                        -- Count players currently inside this specific room area
                        local occupants = 0
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                if (player.Character.HumanoidRootPart.Position - doorPart.Position).Magnitude <= 12 then
                                    occupants = occupants + 1
                                end
                            end
                        end
                        
                        -- If room has open capacity for us to hit the exact target number, move there automatically
                        if occupants < requiredCount and (doorPart.Position - hrp.Position).Magnitude > 8 then
                            self.LastShift = tick()
                            hrp.CFrame = doorPart.CFrame + Vector3.new(0, 3, 0)
                            break
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Mingle MingleSmartMover Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Mingle MingleSmartMover Disabled.")
    end
end

return MingleSmartMover
