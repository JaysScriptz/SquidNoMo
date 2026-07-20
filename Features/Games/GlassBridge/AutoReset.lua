local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SafeLanding = { Enabled = false }

function SafeLanding:Toggle(state)
    self.Enabled = state
    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- If Y-level is below the bridge (e.g., -50), snap to start
        if hrp and hrp.Position.Y < -20 then
            hrp.CFrame = CFrame.new(0, 50, 0) -- Set to your map's start coordinates
        end
    end)
end

return SafeLanding
