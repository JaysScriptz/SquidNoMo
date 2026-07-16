repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Existing = PlayerGui:FindFirstChild("SquidNoMo")
if Existing then
    Existing:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SquidNoMo"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, 350, 0, 220)
Window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Window.BorderSizePixel = 0
Window.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Window

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "SquidNoMo"
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Window

print("Milestone 1 Loaded")
