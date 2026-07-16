-- library.lua
local Library = {}
Library.__index = Library

function Library:New(title)
    local self = setmetatable({}, Library)
    local sg = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
    sg.Name = "SquidNoMoUI"
    sg.DisplayOrder = 999
    
    self.Main = Instance.new("Frame", sg)
    self.Main.Size = UDim2.new(0, 600, 0, 400)
    self.Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.Main.Active = true
    self.Main.Draggable = true
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 8)
    
    self.ContentContainer = Instance.new("Frame", self.Main)
    self.ContentContainer.Size = UDim2.new(1, -150, 1, 0)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 0)
    self.ContentContainer.BackgroundTransparency = 1
    
    return self
end

function Library:AddButton(parent, name, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Active = true
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

return Library
