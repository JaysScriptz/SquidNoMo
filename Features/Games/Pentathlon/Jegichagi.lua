local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local Jegichagi = { Enabled = false }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("JegichagiGui", true) or playerGui:FindFirstChild("JegiGui", true)
    return gui and gui.Enabled
end

function Jegichagi:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            local meter = playerGui and (playerGui:FindFirstChild("JegichagiGui", true) or playerGui:FindFirstChild("Meter", true))
            
            if meter then
                local indicator = meter:FindFirstChild("Indicator") or meter:FindFirstChild("Pointer")
                local sweetSpot = meter:FindFirstChild("SweetSpot") or meter:FindFirstChild("BlueZone")
                
                if indicator and sweetSpot then
                    local indPos = indicator.AbsolutePosition.X
                    local targetPos = sweetSpot.AbsolutePosition.X
                    local targetSize = sweetSpot.AbsoluteSize.X
                    local targetMax = targetPos + targetSize
                    
                    -- Define a small safety buffer (e.g., 15% from the outer edges)
                    local buffer = targetSize * 0.15
                    
                    -- Check if inside the zone
                    local isInside = indPos >= targetPos and indPos <= targetMax
                    
                    -- If it's getting dangerously close to either edge or drifting outside, force a corrective click immediately
                    if isInside then
                        -- If it's drifting toward the left or right boundary, tap to keep it centered
                        if indPos <= (targetPos + buffer) or indPos >= (targetMax - buffer) then
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                        end
                    else
                        -- If it slipped outside, click instantly to recover back into the zone
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                    end
                    
                    task.wait(0.02) -- High frequency monitoring loop
                end
            end
        end)
        print("[SquidNoMo]: Jegichagi Predictive Kicker Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Jegichagi Script Disabled.")
    end
end

return Jegichagi
