local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RecoveryAssist = { Enabled = false, LastSafeCFrame = nil }

function RecoveryAssist:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = character.HumanoidRootPart
            local ring = Workspace:FindFirstChild("MarbleRing") or Workspace:FindFirstChild("Ring")
            
            if ring and ring.PrimaryPart or ring:FindFirstChildWhichIsA("BasePart") then
                local ringPart = ring.PrimaryPart or ring:FindFirstChildWhichIsA("BasePart")
                local distFromRing = (hrp.Position - ringPart.Position).Magnitude
                
                -- Update safe position while near the ring
                if distFromRing < 40 then
                    self.LastSafeCFrame = hrp.CFrame
                -- If flung or knocked completely out of bounds, recover back to the last safe spot
                elseif distFromRing > 80 and self.LastSafeCFrame then
                    hrp.CFrame = self.LastSafeCFrame
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        print("[SquidNoMo]: Marbles RecoveryAssist Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: Marbles RecoveryAssist Disabled.")
    end
end

return RecoveryAssist
