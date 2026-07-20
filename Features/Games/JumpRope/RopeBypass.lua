local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RopeBypass = { Enabled = false }

function RopeBypass:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local rope = Workspace:FindFirstChild("JumpRope") or Workspace:FindFirstChild("Rope")
            if rope then
                if rope:IsA("BasePart") then
                    rope.CanCollide = false
                elseif rope:IsA("Model") then
                    for _, part in ipairs(rope:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: JumpRope RopeBypass Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: JumpRope RopeBypass Disabled.")
    end
end

return RopeBypass
