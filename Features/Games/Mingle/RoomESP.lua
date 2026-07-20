local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RoomESP = { Enabled = false, Highlights = {} }

function RoomESP:Toggle(state)
    self.Enabled = state
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            local doorsFolder = Workspace:FindFirstChild("MingleRooms") or Workspace:FindFirstChild("Doors")
            if not doorsFolder then return end
            
            for _, door in ipairs(doorsFolder:GetChildren()) do
                if door:IsA("BasePart") or door:IsA("Model") then
                    local primary = door:IsA("Model") and door.PrimaryPart or door
                    if primary and not primary:FindFirstChild("RoomHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "RoomHighlight"
                        hl.Adornee = door
                        hl.FillColor = Color3.fromRGB(0, 255, 100)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = primary
                        table.insert(self.Highlights, hl)
                    end
                end
            end
        end)
        print("[SquidNoMo]: Mingle RoomESP Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        for _, hl in ipairs(self.Highlights) do if hl then hl:Destroy() end end
        self.Highlights = {}
        print("[SquidNoMo]: Mingle RoomESP Disabled.")
    end
end

return RoomESP
