-- SquidNoMo v1.0.0 | Master Build
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Destroy old UI
if PlayerGui:FindFirstChild("SquidNoMo") then PlayerGui.SquidNoMo:Destroy() end

local SG = Instance.new("ScreenGui", PlayerGui)
SG.Name = "SquidNoMo"
SG.IgnoreGuiInset = true

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0.6, 0, 0.6, 0)
Main.Position = UDim2.new(0.2, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Allows mobile dragging

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0.25, 0, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0

-- Helper for Buttons
local function CreateButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, 10)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Add Tabs
CreateButton("Player", Sidebar, function() print("Switching to Player") end)
CreateButton("Games", Sidebar, function() print("Switching to Games") end)
CreateButton("Guard", Sidebar, function() print("Switching to Guard") end)

print("SquidNoMo UI Initialized.")
