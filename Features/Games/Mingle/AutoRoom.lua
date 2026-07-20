local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MingleAutoJoin = { Enabled = false, LastAction = 0 }

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

function MingleAutoJoin:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            if tick() - self.LastAction < 1.0 then return end
            
            local requiredCount = getRequiredCount()
            if not requiredCount then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            -- Search workspace doors/rooms for the matching capacity or door tag
            local doorsFolder = Workspace:FindFirstChild("MingleRooms") or Workspace:FindFirstChild("Doors") or Workspace:FindFirstChild("Rooms")
            local targetDoor = nil
            
            if doorsFolder then
                for _, door in ipairs(doorsFolder:GetChildren()) do
                    if door:IsA("BasePart") or door:IsA("Model") then
                        local doorPart = door:IsA("Model") and door.PrimaryPart or door
                        if doorPart then
                            -- Check if door capacity matches the required group size
                            if door.Name:match(tostring(requiredCount)) or (door:FindFirstChild("Capacity") and door.Capacity.Value == requiredCount) then
                                targetDoor = doorPart
                                break
                            end
                        end
                    end
                end
            end
            
            if targetDoor then
                self.LastAction = tick()
                hrp.CFrame = targetDoor.CFrame + Vector3.new(0, 3, 0)
                
                -- Fire room selection remote event to lock in position
                local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
                if eventsFolder then
                    for _, remote in ipairs(eventsFolder:GetChildren()) do
                        if remote:IsA("RemoteEvent") and (remote.Name:lower():match("mingle") or remote.Name:lower():match("room") or remote.Name:lower():match("door") or remote.Name:lower():match("enter")) then
                            pcall(function()
                                remote:FireServer(requiredCount)
                            end)
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Mingle MingleAutoJoin Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Mingle MingleAutoJoin Disabled.")
    end
end

return MingleAutoJoin
