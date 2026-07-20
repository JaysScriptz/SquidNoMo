local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local KitchenCookedHandler = { Enabled = false, ActionCooldown = 0, MaxInteractRange = 15 }

local function interactWithTarget(targetPart)
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    else
        local clickDetector = targetPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then fireclickdetector(clickDetector) end
    end
end

-- Checks inventory specifically for a finished/cooked meal
local function getCookedFoodTool(player)
    local inventory = player.Backpack:GetChildren()
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do table.insert(inventory, item) end
    end
    
    for _, item in ipairs(inventory) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:match("cooked") or name:match("meal") or name:match("food") then
                return item
            end
        end
    end
    return nil
end

function KitchenCookedHandler:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.ActionCooldown < 0.5 then return end
            
            local localPlayer = Players.LocalPlayer
            local character = localPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local kitchenFolder = Workspace:FindFirstChild("Kitchen") or Workspace:FindFirstChild("FoodStations") or Workspace
            local cookedTool = getCookedFoodTool(localPlayer)
            
            -- PHASE 1: If we HAVE cooked food, prioritize storing it in the cabinet
            if cookedTool then
                for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local partName = obj.Name:lower()
                        if partName:match("cabinet") or partName:match("storage") or partName:match("tray") then
                            local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                            local dist = (targetPos - character.HumanoidRootPart.Position).Magnitude
                            
                            -- Strict local distance check
                            if dist <= self.MaxInteractRange then
                                if cookedTool.Parent == localPlayer.Backpack then
                                    cookedTool.Parent = character
                                end
                                interactWithTarget(obj)
                                self.ActionCooldown = tick()
                                return
                            end
                        end
                    end
                end
                return -- Stop executing further if we are currently holding food but not near a cabinet
            end
            
            -- PHASE 2: If we DO NOT have cooked food, look for pots to grab finished food from
            -- (Assuming raw supplies are handled by the separate KitchenPotCooker script)
            local currentEquipped = character:FindFirstChildOfClass("Tool")
            if not currentEquipped then -- Ensure hands are completely empty to grab from pot
                for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local partName = obj.Name:lower()
                        if partName:match("pot") or partName:match("stove") then
                            
                            -- Verify if the pot has an active prompt (ready to be grabbed)
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                            if prompt and prompt.Enabled then
                                -- Optional: You can add a check for prompt.ActionText == "Grab" if the game uses specific text
                                local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                                local dist = (targetPos - character.HumanoidRootPart.Position).Magnitude
                                
                                if dist <= self.MaxInteractRange then
                                    interactWithTarget(obj)
                                    self.ActionCooldown = tick()
                                    return
                                end
                            end
                            
                        end
                    end
                end
            end
            
        end)
        print("[SquidNoMo]: KitchenCookedHandler Enabled. Managing Pot-to-Cabinet transfers.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: KitchenCookedHandler Disabled.")
    end
end

return KitchenCookedHandler
