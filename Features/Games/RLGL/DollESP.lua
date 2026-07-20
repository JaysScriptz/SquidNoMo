local DollESP = {
    Enabled = false,
    Highlight = nil,
    Connection = nil,
    ValidNames = {"Doll", "RedLightDoll", "Killer", "SquidDoll", "Mugunghwa"},
}

-- CONFIG: Adjust this function to match how your specific game tells you it's "Red Light"
local function isRedLight()
    local status = workspace:FindFirstChild("GameStatus", true) or 
                   workspace:FindFirstChild("Status", true)
    if status then
        local val = tostring(status.Value):lower()
        return val:match("red") or val == "stop"
    end
    return false -- Default to Green if status is unknown
end

function DollESP:Toggle(state)
    self.Enabled = state
    
    if state then
        -- 1. Find the doll
        local foundDoll = nil
        for _, name in ipairs(self.ValidNames) do
            foundDoll = workspace:FindFirstChild(name, true)
            if foundDoll then break end
        end

        if not foundDoll then
            warn("[SquidNoMo]: No Doll detected.")
            self.Enabled = false
            return
        end

        -- 2. Setup Highlight
        self.Highlight = Instance.new("Highlight")
        self.Highlight.Name = "DollESP"
        self.Highlight.Adornee = foundDoll
        self.Highlight.FillTransparency = 0.4
        self.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        self.Highlight.Parent = foundDoll

        -- 3. Loop to update color based on state
        task.spawn(function()
            while self.Enabled do
                if self.Highlight and self.Highlight.Parent then
                    local red = isRedLight()
                    self.Highlight.FillColor = red and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
                    self.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                task.wait(0.2) -- Check state 5 times per second
            end
        end)
        
        print("[SquidNoMo]: Doll ESP (Dynamic) Enabled.")
    else
        if self.Highlight then self.Highlight:Destroy() end
        self.Highlight = nil
        print("[SquidNoMo]: Doll ESP Disabled.")
    end
end

return DollESP
