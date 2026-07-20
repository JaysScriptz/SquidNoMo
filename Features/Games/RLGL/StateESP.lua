local StateESP = {
    Enabled = false,
    Gui = nil,
}

-- CONFIG: Adjust this function to match your game's specific Status object
local function isRedLight()
    -- Look for common status paths
    local status = workspace:FindFirstChild("GameStatus", true) or 
                   workspace:FindFirstChild("Status", true) or
                   game.ReplicatedStorage:FindFirstChild("Status", true)
                   
    if status then
        local val = tostring(status.Value):lower()
        return val:match("red") or val == "stop" or val == "danger"
    end
    return false
end

function StateESP:Toggle(state)
    self.Enabled = state
    
    if state then
        self.Gui = Instance.new("ScreenGui")
        self.Gui.Name = "StateESP_Gui"
        self.Gui.Parent = game.CoreGui
        
        local label = Instance.new("TextLabel", self.Gui)
        label.Size = UDim2.new(0, 400, 0, 100)
        label.Position = UDim2.new(0.5, -200, 0.2, 0) -- Center top-ish
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0 -- Makes text readable on all backgrounds
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        -- Update Loop
        task.spawn(function()
            while self.Enabled do
                if self.Gui and label then
                    local red = isRedLight()
                    label.Text = red and "RED LIGHT" or "GREEN LIGHT"
                    label.TextColor3 = red and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
                end
                task.wait(0.1)
            end
        end)
        
        print("[SquidNoMo]: State ESP Enabled.")
    else
        if self.Gui then self.Gui:Destroy() end
        print("[SquidNoMo]: State ESP Disabled.")
    end
end

return StateESP
