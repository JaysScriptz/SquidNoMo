local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CourtBoundaryKeeper = { Enabled = false }

function CourtBoundaryKeeper:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            -- Locate court boundary model/part
            local court = Workspace:FindFirstChild("SquidCourt") or Workspace:FindFirstChild("SquidGameField") or Workspace:FindFirstChild("FinalArena")
            if court then
                local centerPos = court:IsA("Model") and court.WorldPivot.Position or court.Position
                local distFromCenter = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(centerPos.X, 0, centerPos.Z)).Magnitude
                
                -- If getting dangerously close to the outer edge (e.g. > 45 studs from center), pull back
                if distFromCenter > 45 then
                    local dirToCenter = (centerPos - hrp.Position).Unit
                    hrp.AssemblyLinearVelocity = Vector3.new(dirToCenter.X * 25, hrp.AssemblyLinearVelocity.Y, dirToCenter.Z * 25)
                end
            end
        end)
        print("[SquidNoMo]: CourtBoundaryKeeper Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: CourtBoundaryKeeper Disabled.")
    end
end

return CourtBoundaryKeeper
