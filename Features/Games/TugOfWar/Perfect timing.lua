local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerfectTiming = { Enabled = false }

local function getTugType()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    local gui = playerGui:FindFirstChild("TugGui", true) or playerGui:FindFirstChild("TugOfWarGui", true) or playerGui:FindFirstChild("PullGui", true)
    if not gui or not gui.Enabled then return nil end
    
    -- Check if it contains a timing meter/bar interface
    local bar = gui:FindFirstChild("Bar", true) or gui:FindFirstChild("Meter", true)
    local indicator = gui:FindFirstChild("Indicator", true) or gui:FindFirstChild("Cursor", true)
    
    if bar and indicator then
        return "Timing", gui, bar, indicator -- Valid for PerfectTiming
    else
        return "ClickMash" -- Not a timing game, PerfectTiming should stay inactive
    end
end

function PerfectTiming:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            -- Detect type; abort if it's a click-mashing variant
            local gameType, gui, bar, indicator = getTugType()
            if gameType ~= "Timing" then return end
            
            -- Automatically fire confirmation event when active on the meter variant
            local eventsFolder = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("Remotes")
            if eventsFolder then
                for _, remote in ipairs(eventsFolder:GetChildren()) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():match("action") or remote.Name:lower():match("timing") or remote.Name:lower():match("pull")) then
                        pcall(function()
                            remote:FireServer(true)
                        end)
                    end
                end
            end
        end)
        print("[SquidNoMo]: TugOfWar PerfectTiming Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: TugOfWar PerfectTiming Disabled.")
    end
end

return PerfectTiming
