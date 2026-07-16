-- Library.lua
local Library = {}
Library.__index = Library

function Library:New(title)
    local self = setmetatable({}, Library)
    local sg = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
    sg.Name = "SquidNoMoUI"
    sg.DisplayOrder = 999
    
    self.Main = Instance.new("Frame", sg)
    self.Main.Size = UDim2.new(0, 500, 0, 300)
    self.Main.Position = UDim2.new(0.5, -250, 0.5, -150)
    self.Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Main.Active = true
    self.Main.Draggable = true
    Instance.new("UICorner", self.Main)
    
    return self
end

function Library:AddButton(name, callback)
    local btn = Instance.new("TextButton", self.Main)
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Active = true
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end
return Library
