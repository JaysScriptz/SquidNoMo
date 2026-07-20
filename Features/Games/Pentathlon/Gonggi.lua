local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local Gonggi = { Enabled = false, State = "WaitingToStart" }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("GonggiGui", true) or playerGui:FindFirstChild("JacksGui", true)
    return gui and gui.Enabled
end

function Gonggi:Toggle(state)
    self.Enabled = state
    self.State = "WaitingToStart"
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            local gui = playerGui and (playerGui:FindFirstChild("GonggiGui", true) or playerGui:FindFirstChild("JacksGui", true))
            
            if not gui then return end
            
            if self.State == "WaitingToStart" then
                -- Step 1: Click the "Play" or "Start" button if present
                local playButton = gui:FindFirstChild("PlayButton", true) or gui:FindFirstChild("Start", true)
                if playButton and playButton:IsA("GuiButton") then
                    -- Simulate a click on the button's center position
                    local pos = playButton.AbsolutePosition + (playButton.AbsoluteSize / 2)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                    self.State = "WaitingForToss"
                    task.wait(1.5) -- Wait for the animation of stones tossing onto the plate
                end
                
            elseif self.State == "WaitingForToss" then
                -- Step 2: Look for stones on the plate that light up white
                local plate = gui:FindFirstChild("Plate", true) or gui:FindFirstChild("StonesContainer", true)
                if plate then
                    for _, child in ipairs(plate:GetChildren()) do
                        -- Check if the stone UI object is glowing white (high RGB values or specific color)
                        if child:IsA("GuiObject") then
                            local color = child.BackgroundColor3
                            -- White check: R, G, and B are all high (close to 255/1)
                            if color.R > 0.8 and color.G > 0.8 and color.B > 0.8 then
                                local pos = child.AbsolutePosition + (child.AbsoluteSize / 2)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                                task.wait(0.3) -- Small delay between picking up individual stones
                                break
                            end
                        end
                    end
                end
                
                -- Check if all stones are cleared to reset or complete
                local remainingStones = 0
                if plate then
                    for _, child in ipairs(plate:GetChildren()) do
                        if child:IsA("GuiObject") and child.Visible then
                            remainingStones = remainingStones + 1
                        end
                    end
                end
                
                if remainingStones == 0 then
                    self.State = "WaitingToStart" -- Reset for the next round
                end
            end
        end)
        print("[SquidNoMo]: Gonggi Auto-Collector Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Gonggi Auto-Collector Disabled.")
    end
end

return Gonggi
