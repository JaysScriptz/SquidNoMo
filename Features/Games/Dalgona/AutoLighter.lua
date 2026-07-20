local AutoLighter = { Enabled = false }
local Players = game:GetService("Players")

function AutoLighter:Toggle(state)
    self.Enabled = state
    local player = Players.LocalPlayer
    
    if state then
        task.spawn(function()
            while self.Enabled do
                local character = player.Character
                local backpack = player:FindFirstChild("Backpack")
                
                -- Find the Lighter in either the character (equipped) or backpack
                local lighter = (character and character:FindFirstChild("Lighter")) 
                             or (backpack and backpack:FindFirstChild("Lighter"))

                if lighter and lighter:IsA("Tool") then
                    -- If it's in the backpack, equip it first
                    if lighter.Parent == backpack then
                        player.Character.Humanoid:EquipTool(lighter)
                    end
                    
                    -- Activate the tool (simulates clicking with it)
                    -- This triggers the heat mechanic in most scripts
                    lighter:Activate()
                else
                    warn("[SquidNoMo]: Lighter not found in inventory.")
                end
                
                task.wait(0.5) -- Adjust based on how fast the game allows activation
            end
        end)
    end
end

return AutoLighter
