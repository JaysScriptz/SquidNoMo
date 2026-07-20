local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AutoPull = { Enabled = false, LastAction = 0 }

local function getTugType()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local gui = playerGui:FindFirstChild("TugGui", true) or playerGui:FindFirstChild("TugOfWarGui", true) or playerGui:FindFirstChild("PullGui", true)
    if not gui or not gui.Enabled then return nil end
    
    -- Check if it's a meter/timing game versus a click-mashing game
    local hasMeter = gui:FindFirstChild("Bar", true) or gui:FindFirstChild("Meter", true) or gui:FindFirstChild("SweetSpot", true)
    if hasMeter then
        return "Timing" -- It's a timing game, AutoPull should stay inactive
    else
        return "ClickMash" -- It's a continuous pulling/clicking game, valid for AutoPull
    end
end

function AutoPull:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            -- Detect type; abort if it's a timing-based variant
            if getTugType() ~= "ClickMash" then return end
            
            -- Throttle automated clicks to match server-side tick limits (approx 10 times per second)
            if tick() - self.LastAction < 0.1 then return end
            self.LastAction = tick()
            
            local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
            if eventsFolder then
                for _, remote in ipairs(eventsFolder:GetChildren()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():match("tug") or remote.Name:lower():match("pull") or remote.Name:lower():match("click")) then
                        pcall(function()
                            remote:FireServer()
                        end)
                    end
                end
            end
        end)
        print("[SquidNoMo]: TugOfWar AutoPull Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: TugOfWar AutoPull Disabled.")
    end
end

return AutoPull
