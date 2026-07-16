-- SquidNoMo Rendering Fix
local SG = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SquidNoMoUI")
if SG then SG:Destroy() end

SG = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
SG.Name = "SquidNoMoUI"

-- Main Background
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0.6, 0, 0.6, 0)
Main.Position = UDim2.new(0.2, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.ZIndex = 1

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0.2, 0, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.ZIndex = 2

-- Settings Text (The Fix)
local SettingsText = Instance.new("TextLabel", Sidebar)
SettingsText.Size = UDim2.new(1, 0, 0, 50)
SettingsText.Text = "Settings"
SettingsText.TextColor3 = Color3.fromRGB(0, 255, 0) -- Bright Green
SettingsText.BackgroundTransparency = 1 -- Transparent background so it doesn't block
SettingsText.ZIndex = 3 -- Must be higher than the background
SettingsText.TextScaled = true -- Ensures text size adjusts correctly
