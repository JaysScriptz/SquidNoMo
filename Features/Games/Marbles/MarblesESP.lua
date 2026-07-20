local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MarbleESP = { Enabled = false, Highlights = {}, Billboards = {} }

function MarbleESP:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local character = Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = character.HumanoidRootPart
            
            local ring = Workspace:FindFirstChild("MarbleRing") or Workspace:FindFirstChild("Ring")
            if not ring then return end
            
            for _, obj in ipairs(ring:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():match("marble") or obj.Name:lower():match("ball")) then
                    -- Add Highlight if missing
                    if not obj:FindFirstChild("MarbleHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MarbleHighlight"
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(255, 100, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Parent = obj
                        table.insert(self.Highlights, highlight)
                    end
                    
                    -- Add Distance BillboardGui if missing
                    if not obj:FindFirstChild("MarbleBillboard") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "MarbleBillboard"
                        billboard.Size = UDim2.new(0, 100, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2, 0)
                        billboard.AlwaysOnTop = true
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "DistanceText"
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextScaled = true
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.Parent = billboard
                        
                        billboard.Parent = obj
                        table.insert(self.Billboards, billboard)
                    else
                        local billboard = obj:FindFirstChild("MarbleBillboard")
                        local textLabel = billboard and billboard:FindFirstChild("DistanceText")
                        if textLabel then
                            local dist = math.floor((obj.Position - hrp.Position).Magnitude)
                            textLabel.Text = dist .. " studs"
                        end
                    end
                end
            end
        end)
        print("[SquidNoMo]: Marbles MarbleESP Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        for _, highlight in ipairs(self.Highlights) do
            if highlight then highlight:Destroy() end
        end
        for _, billboard in ipairs(self.Billboards) do
            if billboard then billboard:Destroy() end
        end
        self.Highlights = {}
        self.Billboards = {}
        print("[SquidNoMo]: Marbles MarbleESP Disabled.")
    end
end

return MarbleESP
