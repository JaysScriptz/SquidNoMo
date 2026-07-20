local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local Biseokchigi = { Enabled = false, IsHolding = false, TargetNames = {"TargetStone", "Marker", "EnemyStone"} }

-- Function to find the target object in the workspace and calculate distance
local function getTargetDistance()
    local player = Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = player.Character.HumanoidRootPart.Position
    
    for _, name in ipairs(Biseokchigi.TargetNames) do
        local target = workspace:FindFirstChild(name, true)
        if target then
            local targetPos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.Position or target:GetPivot().Position) or (target:IsA("BasePart") and target.Position)
            if targetPos then
                return (targetPos - myPos).Magnitude
            end
        end
    end
    return nil
end

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("BiseokchigiGui", true) or playerGui:FindFirstChild("ThrowMeterGui", true)
    return gui and gui.Enabled
end

function Biseokchigi:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then
                if self.IsHolding then
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                    self.IsHolding = false
                end
                return
            end
            
            -- 1. Calculate required power based on distance
            local distance = getTargetDistance()
            local requiredPower = 0.5 -- Default fallback power (50%)
            
            if distance then
                -- Map distance to a power scale (e.g., min distance 10 studs = 30% power, max 100 studs = 95% power)
                -- Adjust these multipliers based on how the game's physics scale
                requiredPower = math.clamp(distance / 100, 0.2, 0.98)
            end
            
            local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            local meter = playerGui and (playerGui:FindFirstChild("BiseokchigiGui", true) or playerGui:FindFirstChild("PowerBar", true))
            
            if meter then
                local fillBar = meter:FindFirstChild("Fill") or meter:FindFirstChild("Bar")
                local currentPower = 0
                
                if fillBar and fillBar:IsA("GuiObject") then
                    currentPower = fillBar.Size.X.Scale
                end
                
                -- 2. Execute hold and release logic matching the dynamic target power
                if not self.IsHolding then
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, true, game, 1)
                    self.IsHolding = true
                elseif currentPower >= requiredPower then
                    VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
                    self.IsHolding = false
                    task.wait(1.5)
                end
            end
        end)
    else
        if self.Connection then self.Connection:Disconnect() end
        if self.IsHolding then
            VirtualInputManager:SendMouseButtonEvent(500, 500, 0, false, game, 1)
            self.IsHolding = false
        end
    end
end

return Biseokchigi
