local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GlassESP = { Enabled = false, Highlights = {} }

function GlassESP:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Connection = RunService.RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            -- Look for glass bridge model or containers in workspace
            local glassBridge = Workspace:FindFirstChild("GlassBridge") or Workspace:FindFirstChild("GlassSteppingStones") or Workspace:FindFirstChild("Bridge")
            if not glassBridge then return end
            
            for _, panel in ipairs(glassBridge:GetDescendants()) do
                if panel:IsA("BasePart") and (panel.Name:lower():match("glass") or panel.Name:lower():match("pane") or panel.Name:lower():match("tile")) then
                    if not panel:FindFirstChild("GlassHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "GlassHighlight"
                        highlight.Adornee = panel
                        
                        -- Analyze glass properties or attributes if the game stores safety data on the client
                        -- Safe/Tempered glass often has slight differences or custom attributes
                        local isSafe = true 
                        pcall(function()
                            -- Some variations store transparency or material properties, or attributes
                            if panel:GetAttribute("IsSafe") ~= nil then
                                isSafe = panel:GetAttribute("IsSafe")
                            end
                        end)
                        
                        if isSafe then
                            highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Green for safe
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        else
                            highlight.FillColor = Color3.fromRGB(255, 50, 50) -- Red for unsafe
                            highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                        end
                        
                        highlight.Parent = panel
                        table.insert(self.Highlights, highlight)
                    end
                end
            end
        end)
        print("[SquidNoMo]: GlassBridge GlassESP Enabled.")
    else
        if self.Connection then self.Connection:Disconnect() end
        for _, highlight in ipairs(self.Highlights) do
            if highlight then highlight:Destroy() end
        end
        self.Highlights = {}
        print("[SquidNoMo]: GlassBridge GlassESP Disabled.")
    end
end

return GlassESP
