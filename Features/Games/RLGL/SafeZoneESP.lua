local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SafeZoneESP = {
    Enabled = false,
    Gui = nil,
    ValidDollNames = {"Doll", "RedLightDoll", "Killer", "SquidDoll", "Mugunghwa"},
}

local function getDoll()
    for _, name in ipairs(SafeZoneESP.ValidDollNames) do
        local found = workspace:FindFirstChild(name, true)
        if found and found:FindFirstChild("HumanoidRootPart") then return found end
    end
    return nil
end

function SafeZoneESP:Toggle(state)
    self.Enabled = state
    local player = Players.LocalPlayer

    if state then
        self.Gui = Instance.new("ScreenGui", game.CoreGui)
        local indicator = Instance.new("TextLabel", self.Gui)
        indicator.Size = UDim2.new(0, 200, 0, 50)
        indicator.Position = UDim2.new(0.5, -100, 0.85, 0)
        indicator.Font = Enum.Font.GothamBold
        indicator.TextSize = 25
        indicator.BackgroundTransparency = 0.5
        indicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Enabled then return end
            local doll = getDoll()
            local char = player.Character
            
            if doll and char and char:FindFirstChild("Head") then
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {doll.Parent} -- Ignore the doll
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude

                -- Cast ray from Doll Head to Player Head
                local origin = doll:FindFirstChild("Head") and doll.Head.Position or doll.HumanoidRootPart.Position
                local direction = (char.Head.Position - origin).Unit * 500
                local result = workspace:Raycast(origin, direction, raycastParams)

                -- If the ray hit something that ISN'T the player, you are safe
                local isVisible = result and result.Instance:IsDescendantOf(char)
                
                indicator.Text = isVisible and "DANGER: VISIBLE" or "SAFE ZONE"
                indicator.TextColor3 = isVisible and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 255)
            end
        end)
    else
        if self.Gui then self.Gui:Destroy() end
        if self.Connection then self.Connection:Disconnect() end
    end
end

return SafeZoneESP
