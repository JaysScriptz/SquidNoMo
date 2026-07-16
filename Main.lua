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

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,50)
Header.BackgroundColor3 = Color3.fromRGB(40,40,40)
Header.BorderSizePixel = 0
Header.Parent = Window

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,15,0,0)
Title.Size = UDim2.new(1,-120,1,0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🦑 SquidNoMo"
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(91,255,98)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.new(1,-95,0,0)
Version.Size = UDim2.new(0,55,1,0)
Version.Font = Enum.Font.Gotham
Version.Text = "v0.0.1"
Version.TextSize = 12
Version.TextColor3 = Color3.fromRGB(180,180,180)
Version.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Position = UDim2.new(1,-40,0.5,-15)
Minimize.Size = UDim2.new(0,30,0,30)
Minimize.BackgroundColor3 = Color3.fromRGB(60,60,60)
Minimize.Text = "—"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BorderSizePixel = 0
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,8)
MinCorner.Parent = Minimize

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.new(0,0,0,50)
Sidebar.Size = UDim2.new(0,155,1,-50)
Sidebar.BackgroundColor3 = Color3.fromRGB(35,35,35)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0,0,0,0)
Sidebar.ScrollBarThickness = 4
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
Sidebar.Parent = Window

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Sidebar

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Sidebar

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,8)
Padding.PaddingBottom = UDim.new(0,8)
Padding.PaddingLeft = UDim.new(0,8)
Padding.PaddingRight = UDim.new(0,8)
Padding.Parent = Sidebar

local Pages = {
    "🏠 Home",
    "🎮 Games",
    "🛡 Guards",
    "🕵 Detective",
    "🌾 Farming",
    "💎 VIP",
    "🖥 Display",
    "⚙ Settings"
}

for i, Name in ipairs(Pages) do
    local Button = Instance.new("TextButton")
    Button.Name = Name
    Button.Size = UDim2.new(1,0,0,38)
    Button.LayoutOrder = i
    Button.BackgroundColor3 = i == 1 and Color3.fromRGB(91,255,98) or Color3.fromRGB(50,50,50)
    Button.TextColor3 = i == 1 and Color3.new(0,0,0) or Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Text = Name
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.Parent = Sidebar

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0,8)
    C.Parent = Button
end

print("Milestone 1 Loaded")
