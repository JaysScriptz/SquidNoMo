local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local IslandExtractionRoute = { Enabled = false }

function IslandExtractionRoute:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            -- Locate extraction vehicle, boat, or finish line zone
            local extractionZone = Workspace:FindFirstChild("ExtractionPoint") or Workspace:FindFirstChild("Boat") or Workspace:FindFirstChild("EscapeBoat") or Workspace:FindFirstChild("FinishLine")
            if extractionZone then
                local targetPos = extractionZone.Position or (extractionZone:IsA("Model") and extractionZone.WorldPivot.Position)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and targetPos then
                    humanoid:MoveTo(targetPos)
                end
            end
        end)
        print("[SquidNoMo]: EscapeIsland IslandExtractionRoute Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        print("[SquidNoMo]: EscapeIsland IslandExtractionRoute Disabled.")
    end
end

return IslandExtractionRoute
