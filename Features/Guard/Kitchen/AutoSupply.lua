local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local KitchenSupplyGrabber = { Enabled = false, ActionCooldown = 0, MaxInteractRange = 15, MaxSupplies = 3 }

local function interactWithTarget(targetPart)
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    else
        local clickDetector = targetPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then fireclickdetector(clickDetector) end
    end
end

local function getSupplyCount(player)
    local count = 0
    local inventory = player.Backpack:GetChildren()
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do table.insert(inventory, item) end
    end
    
    for _, item in ipairs(inventory) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:match("meat") or name:match("bread") or name:match("raw") or name:match("supply") then
                count = count + 1
            end
        end
    end
    return count
end

-- Checks the kitchen to see if there is at least one open pot ready to cook
local function arePotsAvailable(kitchenFolder)
    local availablePots = 0
    
    for _, obj in ipairs(kitchenFolder:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local partName = obj.Name:lower()
            if partName:match("pot") or partName:match("stove") then
                
                -- Check if the pot has an active interaction prompt
                local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                local cd = obj:FindFirstChildOfClass("ClickDetector")
                
                -- If it has an enabled prompt, it means it is empty and ready for raw food
                if (prompt and prompt.Enabled) or cd then
                    availablePots = availablePots + 1
                end
            end
        end
    end
    
    return availablePots > 0
end

function KitchenSupplyGrabber:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.ActionCooldown < 0.5 then return end
            
            local localPlayer = Players.LocalPlayer
            local character = localPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local kitchenFolder = Workspace:FindFirstChild("Kitchen") or Workspace:FindFirstChild("FoodStations") or Workspace
            
            -- 1. Check if all pots are currently full/cooking
            if not arePotsAvailable(kitchenFolder) then
                return -- Stop executing; all pots are currently occupied
            end
            
            -- 2. Check if we already have the max allowed supplies in our inventory
            local currentSupplies = getSupplyCount(localPlayer)
            if currentSupplies >= self.MaxSupplies then return end 
            
            -- 3. Proceed to grab supplies
            for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local partName = obj.Name:lower()
                    if partName:match("meat") or partName:match("bread") or partName:match("supply") then
                        local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        local dist = (targetPos - character.HumanoidRootPart.Position).Magnitude
                        
                        -- Strictly limit to local distance
                        if dist <= self.MaxInteractRange then
                            interactWithTarget(obj)
                            self.ActionCooldown = tick()
                            return
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: KitchenSupplyGrabber Enabled. Checking Pot Availability.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: KitchenSupplyGrabber Disabled.")
    end
end

return KitchenSupplyGrabber
