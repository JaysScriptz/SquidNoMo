local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local KitchenPotCooker = { Enabled = false, ActionCooldown = 0, MaxInteractRange = 15 }

local function interactWithTarget(targetPart)
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    else
        local clickDetector = targetPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then fireclickdetector(clickDetector) end
    end
end

-- Scans inventory (equipped and unequipped) for raw supplies
local function getRawSupplyTool(player)
    local inventory = player.Backpack:GetChildren()
    if player.Character then
        for _, item in ipairs(player.Character:GetChildren()) do table.insert(inventory, item) end
    end
    
    for _, item in ipairs(inventory) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:match("raw") or name:match("meat") or name:match("bread") then
                return item
            end
        end
    end
    return nil
end

function KitchenPotCooker:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if tick() - self.ActionCooldown < 0.5 then return end
            
            local localPlayer = Players.LocalPlayer
            local character = localPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rawTool = getRawSupplyTool(localPlayer)
            if not rawTool then return end -- Abort if we have 0 raw supplies
            
            local kitchenFolder = Workspace:FindFirstChild("Kitchen") or Workspace:FindFirstChild("FoodStations") or Workspace
            
            for _, obj in ipairs(kitchenFolder:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local partName = obj.Name:lower()
                    if partName:match("pot") or partName:match("stove") then
                        
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and prompt.Enabled then
                            -- CRITICAL FIX: Ensure the prompt is for placing food, not taking a finished meal
                            local actionText = prompt.ActionText:lower()
                            if actionText:match("place") or actionText:match("cook") or actionText:match("put") or actionText:match("add") or actionText == "interact" then
                                
                                local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                                local dist = (targetPos - character.HumanoidRootPart.Position).Magnitude
                                
                                -- Strict local distance check
                                if dist <= self.MaxInteractRange then
                                    -- Auto-equip the raw food tool before interacting
                                    if rawTool.Parent == localPlayer.Backpack then
                                        rawTool.Parent = character
                                    end
                                    
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
        print("[SquidNoMo]: KitchenPotCooker Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: KitchenPotCooker Disabled.")
    end
end

return KitchenPotCooker
