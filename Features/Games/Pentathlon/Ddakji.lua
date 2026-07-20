local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Ddakji = { Enabled = false }

function Ddakji:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if not playerGui then return end
            
            -- Find the meter bar and the indicator/marker
            local meter = playerGui:FindFirstChild("DdakjiGui", true) or playerGui:FindFirstChild("Meter", true)
            if meter then
                local indicator = meter:FindFirstChild("Indicator") or meter:FindFirstChild("Pointer")
                local sweetSpot = meter:FindFirstChild("SweetSpot") or meter:FindFirstChild("BlueZone")
                
                if indicator and sweetSpot then
                    -- Check if indicator position matches the sweet spot position
                    local indPos = indicator.AbsolutePosition.X
                    local targetPos = sweetSpot.AbsolutePosition.X
                    local targetSize = sweetSpot.AbsoluteSize.X
                    
                    -- If the pointer is within the blue zone bounds, click!
                    if indPos >= targetPos and indPos <= (targetPos + targetSize) then
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                        task.wait(0.5) -- Cooldown to let the throw execute
                    end
                end
            end
        end)
        print("[SquidNoMo]: Ddakji Auto-Throw Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Ddakji Auto-Throw Disabled.")
    end
end

return Ddakji
