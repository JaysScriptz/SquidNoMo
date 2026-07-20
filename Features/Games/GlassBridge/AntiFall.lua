local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AntiFall = { Enabled = false, LastSafePos = nil }

function AntiFall:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            local char = Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- If we are above a certain height, update our "Last Safe" position
            if hrp.Position.Y > 20 then 
                self.LastSafePos = hrp.CFrame 
            elseif self.LastSafePos and hrp.Position.Y < 5 then
                -- If we fall below the bridge level, snap back
                hrp.CFrame = self.LastSafePos
            end
        end)
    else
        if self.Connection then self.Connection:Disconnect() end
    end
end

return AntiFall
