local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AntiStuck = {
    Enabled = false,
    Connection = nil,
}

-- Detects Red Light status
local function isRedLight()
    local status = workspace:FindFirstChild("GameStatus", true) or workspace:FindFirstChild("Status", true)
    if status then
        local val = tostring(status.Value):lower()
        return val:match("red") or val == "stop"
    end
    return false
end

function AntiStuck:Toggle(state)
    self.Enabled = state
    local player = Players.LocalPlayer

    if state then
        -- Use Heartbeat for frame-perfect physics control
        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Enabled then return end
            
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                
                if isRedLight() then
                    -- Kill momentum instantly
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        print("[SquidNoMo]: AntiStuck Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: AntiStuck Disabled.")
    end
end

return AntiStuck
