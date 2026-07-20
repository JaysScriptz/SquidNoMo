local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EvidenceESP = { Enabled = false, Markers = {} }

-- Configuration
local ESP_COLOR = Color3.fromRGB(0, 255, 255) -- Cyan
local TEXT_LABEL = "Evidence"

function EvidenceESP:CreateMarker(target)
    if target:FindFirstChild("EvidenceHighlight") then return end

    -- 1. Create Outline
    local hl = Instance.new("Highlight")
    hl.Name = "EvidenceHighlight"
    hl.Adornee = target
    hl.FillColor = ESP_COLOR
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.5
    hl.Parent = target

    -- 2. Create Distance Label
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EvidenceLabel"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = ESP_COLOR
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = TEXT_LABEL
    label.Parent = billboard

    table.insert(self.Markers, {Highlight = hl, Billboard = billboard})
end

function EvidenceESP:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            -- Scan for items that match common evidence names or tags
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:match("evidence") or name:match("clue") or name:match("file") or name:match("keycard") then
                        if not obj:FindFirstChild("EvidenceHighlight") then
                            self:CreateMarker(obj)
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: EvidenceESP Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        -- Cleanup all existing markers
        for _, marker in ipairs(self.Markers) do
            if marker.Highlight then marker.Highlight:Destroy() end
            if marker.Billboard then marker.Billboard:Destroy() end
        end
        self.Markers = {}
        print("[SquidNoMo]: EvidenceESP Disabled.")
    end
end

return EvidenceESP
