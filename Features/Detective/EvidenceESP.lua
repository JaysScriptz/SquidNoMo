local Workspace = game:GetService("Workspace")

local EvidenceESP = { Enabled = false, Markers = {}, Worker = nil }
local ESP_COLOR = Color3.fromRGB(0, 255, 255)

local function isEvidence(target)
    if not (target:IsA("BasePart") or target:IsA("Model")) then return false end
    local name = target.Name:lower()
    return name:find("evidence", 1, true)
        or name:find("clue", 1, true)
        or name:find("file", 1, true)
        or name:find("keycard", 1, true)
end

function EvidenceESP:CreateMarker(target)
    if target:FindFirstChild("EvidenceHighlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EvidenceHighlight"
    highlight.Adornee = target
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = target

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EvidenceLabel"
    billboard.Size = UDim2.fromOffset(120, 52)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = target:IsA("BasePart") and target or target.PrimaryPart
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = ESP_COLOR
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "Evidence"
    label.Parent = billboard

    self.Markers[target] = {Highlight = highlight, Billboard = billboard}
end

function EvidenceESP:Cleanup()
    for target, marker in pairs(self.Markers) do
        if marker.Highlight then marker.Highlight:Destroy() end
        if marker.Billboard then marker.Billboard:Destroy() end
        self.Markers[target] = nil
    end
end

function EvidenceESP:Toggle(state)
    state = state == true
    if self.Enabled == state then return end
    self.Enabled = state
    if self.Worker then task.cancel(self.Worker); self.Worker = nil end
    if not state then self:Cleanup(); return end

    self.Worker = task.spawn(function()
        while self.Enabled do
            for _, object in ipairs(Workspace:GetDescendants()) do
                if isEvidence(object) and not self.Markers[object] then self:CreateMarker(object) end
            end
            for target, marker in pairs(self.Markers) do
                if not target.Parent then
                    if marker.Highlight then marker.Highlight:Destroy() end
                    if marker.Billboard then marker.Billboard:Destroy() end
                    self.Markers[target] = nil
                end
            end
            task.wait(1.5)
        end
        self.Worker = nil
    end)
end

function EvidenceESP:IsEnabled()
    return self.Enabled
end

return EvidenceESP
