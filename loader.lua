-- SquidNoMo Unified Loader (Delta Optimized)
local Core = {}
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Initialize UI Container
local SG = Instance.new("ScreenGui", PlayerGui)
SG.Name = "SquidNoMoUI"
SG.IgnoreGuiInset = true

-- Main Panel (Professional Dark Theme)
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 700, 0, 450)
Main.Position = UDim2.new(0.5, -350, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Tab System (Delta uses standard instance parenting)
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

-- Add Tabs logic
function Core:AddTab(name, icon)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    -- Add your Tab Switching logic here
end

return Core
