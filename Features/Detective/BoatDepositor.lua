local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Navigator = require(script.Parent.Parent.IslandNavigator)

local BoatDepositor = { Enabled = false }

function BoatDepositor:Toggle(state)
    self.Enabled = state
    task.spawn(function()
        while self.Enabled do
            local char = Players.LocalPlayer.Character
            -- Check if holding evidence tool
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and (tool.Name:lower():match("evidence") or tool.Name:lower():match("clue")) then
                local boat = Workspace:FindFirstChild("Boat", true) or Workspace:FindFirstChild("Escape", true)
                if boat then
                    Navigator:NavigateTo(boat:GetPivot().Position)
                    -- Trigger deposit interaction
                    local prompt = boat:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt then fireproximityprompt(prompt) end
                end
            end
            task.wait(2)
        end
    end)
end

return BoatDepositor
