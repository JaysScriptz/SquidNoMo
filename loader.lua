-- SquidNoMo Unified Loader
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 1. Create Window
local SG = Instance.new("ScreenGui", PlayerGui)
SG.Name = "SquidNoMoUI"
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 500, 0, 300)
Main.Position = UDim2.new(0.5, -250, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- 2. Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", Sidebar)

-- 3. Feature Logic
local function AddButton(name, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 150, 0, 40)
    btn.Position = UDim2.new(0, 130, 0, (#Main:GetChildren() - 2) * 50)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    Instance.new("UICorner", btn)
end

AddButton("Speed 50", function() Player.Character.Humanoid.WalkSpeed = 50 end)
AddButton("Jump 100", function() Player.Character.Humanoid.JumpPower = 100 end)
print("SquidNoMo Loaded Unified")
