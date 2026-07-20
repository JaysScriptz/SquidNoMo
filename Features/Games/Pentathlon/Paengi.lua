local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local Paengi = { Enabled = false, State = "TracingDots", LastIndex = 0 }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("PaengiGui", true) or playerGui:FindFirstChild("TopGui", true)
    return gui and gui.Enabled
end

function Paengi:Toggle(state)
    self.Enabled = state
    self.State = "TracingDots"
    self.LastIndex = 0
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            local gui = playerGui and (playerGui:FindFirstChild("PaengiGui", true) or playerGui:FindFirstChild("TopGui", true))
            if not gui then return end
            
            if self.State == "TracingDots" then
                -- Look for the container holding the sequential dots
                local dotContainer = gui:FindFirstChild("DotsContainer", true) or gui:FindFirstChild("ShapeDots", true)
                if dotContainer then
                    local dots = {}
                    
                    -- Gather and sort dots by their designated order (usually named 1, 2, 3... or Dot1, Dot2)
                    for _, child in ipairs(dotContainer:GetChildren()) do
                        if child:IsA("GuiObject") then
                            local index = tonumber(child.Name:match("%d+"))
                            if index then
                                dots[index] = child
                            end
                        end
                    end
                    
                    -- Find the next dot in sequence to connect
                    local nextIndex = self.LastIndex + 1
                    local targetDot = dots[nextIndex]
                    
                    if targetDot and targetDot.Visible then
                        local pos = targetDot.AbsolutePosition + (targetDot.AbsoluteSize / 2)
                        -- Simulate drag/click from dot to dot
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                        self.LastIndex = nextIndex
                        task.wait(0.15) -- Quick pacing between dot connections
                    else
                        -- If all numbered dots are connected, transition to the final safe zone phase
                        if self.LastIndex >= 5 then 
                            self.State = "TimingSafeZone"
                        end
                    end
                end
                
            elseif self.State == "TimingSafeZone" then
                -- Reuse the Ddakji/Safe Zone logic for the final throw/spin release
                local meter = gui:FindFirstChild("Meter") or gui:FindFirstChild("SafeZoneBar")
                if meter then
                    local indicator = meter:FindFirstChild("Indicator") or meter:FindFirstChild("Pointer")
                    local sweetSpot = meter:FindFirstChild("SweetSpot") or meter:FindFirstChild("BlueZone")
                    
                    if indicator and sweetSpot then
                        local indPos = indicator.AbsolutePosition.X
                        local targetPos = sweetSpot.AbsolutePosition.X
                        local targetSize = sweetSpot.AbsoluteSize.X
                        
                        -- Click when the indicator enters the safe zone
                        if indPos >= targetPos and indPos <= (targetPos + targetSize) then
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                            task.wait(1.5) -- Cooldown before resetting loop
                            self.State = "TracingDots"
                            self.LastIndex = 0
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Paengi Auto-Tracer & Spinner Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Paengi Script Disabled.")
    end
end

return Paengi
