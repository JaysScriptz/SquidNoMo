local MapRadar = {
    Enabled = false,
    Gui = nil,
    RadarSize = 150, 
    ViewRadius = 100,
}

function MapRadar:Toggle(state)
    self.Enabled = state
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera

    if state then
        self.Gui = Instance.new("ScreenGui")
        self.Gui.Name = "RadarGui"
        self.Gui.Parent = game.CoreGui

        -- Square Frame (No circular corner clamping)
        local frame = Instance.new("Frame", self.Gui)
        frame.Size = UDim2.new(0, self.RadarSize, 0, self.RadarSize)
        frame.Position = UDim2.new(0.02, 0, 0.7, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.6
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        frame.ClipsDescendants = true
        
        -- Player Icon (The Triangle)
        local playerIcon = Instance.new("ImageLabel", frame)
        playerIcon.Name = "PlayerIcon"
        playerIcon.Size = UDim2.new(0, 20, 0, 20)
        playerIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
        playerIcon.BackgroundTransparency = 1
        playerIcon.Image = "rbxassetid://6023426923" -- White triangle icon
        playerIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Enabled then return end
            
            -- Cleanup previous enemy dots
            for _, child in ipairs(frame:GetChildren()) do
                if child:IsA("Frame") and child.Name == "EnemyDot" then 
                    child:Destroy() 
                end
            end

            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Rotate Player Icon based on Camera Yaw orientation
            local _, cameraYaw, _ = Camera.CFrame:ToOrientation()
            playerIcon.Rotation = -math.deg(cameraYaw)

            for _, other in ipairs(game.Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = other.Character.HumanoidRootPart.Position
                    
                    -- Static North-Up Logic: Absolute position distance relative to player
                    local relX = targetPos.X - hrp.Position.X
                    local relZ = targetPos.Z - hrp.Position.Z

                    -- Check if enemy is within radar range
                    if math.sqrt(relX^2 + relZ^2) < self.ViewRadius then
                        local dot = Instance.new("Frame", frame)
                        dot.Name = "EnemyDot"
                        dot.Size = UDim2.new(0, 6, 0, 6)
                        dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red
                        dot.BorderSizePixel = 0
                        
                        -- Add subtle rounded styling to enemy dots
                        local dotCorner = Instance.new("UICorner", dot)
                        dotCorner.CornerRadius = UDim.new(1, 0)
                        
                        -- Map world coordinates to square UI space
                        local uiX = (relX / self.ViewRadius) * (self.RadarSize / 2)
                        local uiY = (relZ / self.ViewRadius) * (self.RadarSize / 2)
                        
                        dot.Position = UDim2.new(0.5, uiX - 3, 0.5, uiY - 3)
                        dot.Parent = frame
                    end
                end
            end
        end)
    else
        if self.Gui then self.Gui:Destroy() end
        if self.Connection then self.Connection:Disconnect() end
    end
end

return MapRadar
