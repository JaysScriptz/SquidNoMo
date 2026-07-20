local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local AutoJump = { Enabled = false }

local function isParticipating()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local gui = playerGui:FindFirstChild("JumpRopeGui", true) or playerGui:FindFirstChild("JpRopeGui", true)
    return gui and gui.Enabled
end

function AutoJump:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            if not isParticipating() then return end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local myPos = character.HumanoidRootPart.Position
            
            local rope = Workspace:FindFirstChild("JumpRope") or Workspace:FindFirstChild("Rope")
            if rope and rope:IsA("BasePart") then
                local ropeDist = (rope.Position - myPos).Magnitude
                if ropeDist < 20 and humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        print("[SquidNoMo]: JumpRope AutoJump Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: JumpRope AutoJump Disabled.")
    end
end

return AutoJump
