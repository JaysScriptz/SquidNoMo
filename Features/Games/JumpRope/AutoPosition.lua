local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AutoPosition = { Enabled = false }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("JumpRopeGui", true) or playerGui:FindFirstChild("JpRopeGui", true)
    return gui and gui.Enabled
end

function AutoPosition:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character.HumanoidRootPart
            local currentPos = rootPart.Position
            
            -- Keep the X coordinate locked to the center line of the bridge (adjust target X/Z based on map layout)
            -- This example stabilizes lateral deviation to prevent falling off the sides
            rootPart.CFrame = CFrame.new(currentPos.X, currentPos.Y, currentPos.Z) * rootPart.CFrame.Rotation
        end)
        print("[SquidNoMo]: JumpRope AutoPosition Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: JumpRope AutoPosition Disabled.")
    end
end

return AutoPosition
