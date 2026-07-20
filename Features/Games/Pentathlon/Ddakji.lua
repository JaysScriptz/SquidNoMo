local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local Ddakji = { Enabled = false }

-- Function to check if the player is actively playing Ddakji right now
local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    -- Look for UI frames or active indicators unique to the Ddakji screen
    local ddakjiGui = playerGui:FindFirstChild("DdakjiGui", true) or playerGui:FindFirstChild("DdakjiUI", true)
    
    if ddakjiGui and ddakjiGui.Enabled then
        return true
    end
    
    -- Alternative check: Look for a game prompt or active title text
    local activeTitle = playerGui:FindFirstChild("GameTitle", true) or playerGui:FindFirstChild("CurrentGame", true)
    if activeTitle and activeTitle:IsA("TextLabel") then
        if activeTitle.Text:lower():match("ddakji") then
            return true
        end
    end
    
    return false
end

function Ddakji:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            -- Only execute code if the participation check passes!
            if not isParticipating() then return end
            
            local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            local meter = playerGui and (playerGui:FindFirstChild("DdakjiGui", true) or playerGui:FindFirstChild("Meter", true))
            
            if meter then
                local indicator = meter:FindFirstChild("Indicator") or meter:FindFirstChild("Pointer")
                local sweetSpot = meter:FindFirstChild("SweetSpot") or meter:FindFirstChild("BlueZone")
                
                if indicator and sweetSpot then
                    local indPos = indicator.AbsolutePosition.X
                    local targetPos = sweetSpot.AbsolutePosition.X
                    local targetSize = sweetSpot.AbsoluteSize.X
                    
                    -- Click when the pointer lands inside the blue target zone
                    if indPos >= targetPos and indPos <= (targetPos + targetSize) then
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                        task.wait(0.5) -- Cooldown between throws
                    end
                end
            end
        end)
        print("[SquidNoMo]: Ddakji Auto-Throw Enabled (Monitoring Participation).")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Ddakji Auto-Throw Disabled.")
    end
end

return Ddakji
