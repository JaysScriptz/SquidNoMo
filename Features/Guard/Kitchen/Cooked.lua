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
            
            -- PHASE 1: Store cooked food in cabinet
            if cookedTool then
                for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local partName = obj.Name:lower()
                        if partName:match("cabinet") or partName:match("storage") or partName:match("tray") then
                            local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                            if (targetPos - character.HumanoidRootPart.Position).Magnitude <= self.MaxInteractRange then
                                if cookedTool.Parent == localPlayer.Backpack then cookedTool.Parent = character end
                                interactWithTarget(obj)
                                self.ActionCooldown = tick()
                                return
                            end
                        end
                    end
                end
                return
            end
            
            -- PHASE 2: Grab finished food from the pot
            local currentEquipped = character:FindFirstChildOfClass("Tool")
            if not currentEquipped then 
                for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local partName = obj.Name:lower()
                        if partName:match("pot") or partName:match("stove") then
                            
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                            if prompt and prompt.Enabled then
                                -- CRITICAL FIX: Ensure the prompt is for taking food, not placing raw meat
                                local actionText = prompt.ActionText:lower()
                                if actionText:match("take") or actionText:match("grab") or actionText:match("collect") then
                                    
                                    local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                                    if (targetPos - character.HumanoidRootPart.Position).Magnitude <= self.MaxInteractRange then
                                        interactWithTarget(obj)
                                        self.ActionCooldown = tick()
                                        return
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end
            
        end)
        print("[SquidNoMo]: KitchenCookedHandler Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: KitchenCookedHandler Disabled.")
    end
end

return KitchenCookedHandler
