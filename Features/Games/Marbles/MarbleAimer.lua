local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MarbleAimer = { Enabled = false, Beam = nil, Attachment0 = nil, Attachment1 = nil }

function MarbleAimer:Toggle(state)
    self.Enabled = state
    
    if state then
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            
            -- Create visual aim line (Beam) to assist with manual or automated shot verification
            self.Attachment0 = Instance.new("Attachment", hrp)
            self.Attachment1 = Instance.new("Attachment", Workspace.Terrain)
            
            self.Beam = Instance.new("Beam")
            self.Beam.Name = "MarbleAimBeam"
            self.Beam.Attachment0 = self.Attachment0
            self.Beam.Attachment1 = self.Attachment1
            self.Beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 150))
            self.Beam.Width0 = 0.2
            self.Beam.Width1 = 0.2
            self.Beam.Parent = hrp
        end
        
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local char = Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            
            -- Locate target inside the ring to point the aim vector toward
            local ring = Workspace:FindFirstChild("MarbleRing") or Workspace:FindFirstChild("Ring")
            local targetPos = nil
            
            if ring then
                for _, obj in ipairs(ring:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():match("marble") or obj.Name:lower():match("ball")) then
                        targetPos = obj.Position
                        break
                    end
                end
            end
            
            if targetPos and self.Attachment1 then
                self.Attachment1.WorldPosition = targetPos
                -- Smoothly rotate character to face the target marble
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
            end
        end)
        print("[SquidNoMo]: Marbles MarbleAimer Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        if self.Beam then self.Beam:Destroy() end
        if self.Attachment0 then self.Attachment0:Destroy() end
        if self.Attachment1 then self.Attachment1:Destroy() end
        self.Beam = nil
        self.Attachment0 = nil
        self.Attachment1 = nil
        print("[SquidNoMo]: Marbles MarbleAimer Disabled.")
    end
end

return MarbleAimer
