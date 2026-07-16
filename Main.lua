repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

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

local Device = "Desktop"

if UIS.TouchEnabled then
    local Camera = workspace.CurrentCamera

    while not Camera do
        task.wait()
        Camera = workspace.CurrentCamera
    end

    local View = Camera.ViewportSize

    if math.min(View.X, View.Y) < 700 then
        Device = "Phone"
    else
        Device = "Tablet"
    end
end

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(.5,.5)
Window.Position = UDim2.new(.5,0,.5,0)

if Device == "Phone" then
    Window.Size = UDim2.new(.94,0,.86,0)
elseif Device == "Tablet" then
    Window.Size = UDim2.new(.82,0,.82,0)
else
    Window.Size = UDim2.fromOffset(1050,650)
end

Window.BackgroundColor3 = Color3.fromRGB(20,20,20)
Window.BorderSizePixel = 0
Window.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,14)
Corner.Parent = Window

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(55,55,55)
Stroke.Parent = Window

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,55)
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.BorderSizePixel = 0
Header.Parent = Window

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18,0)
Title.Size = UDim2.new(1,-120,1,0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🦑 SquidNoMo 🎯"
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(91,255,98)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Hide = Instance.new("TextButton")
Hide.Size = UDim2.fromOffset(36,36)
Hide.Position = UDim2.new(1,-46,0,10)
Hide.Text = "-"
Hide.Font = Enum.Font.GothamBold
Hide.TextSize = 24
Hide.TextColor3 = Color3.new(1,1,1)
Hide.BackgroundColor3 = Color3.fromRGB(45,45,45)
Hide.BorderSizePixel = 0
Hide.Parent = Header

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0,8)
HC.Parent = Hide

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,200,1,-55)
Sidebar.Position = UDim2.new(0,0,0,55)
Sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,8)
Layout.Parent = Sidebar

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,10)
Padding.PaddingLeft = UDim.new(0,10)
Padding.PaddingRight = UDim.new(0,10)
Padding.Parent = Sidebar

local Tabs = {
    "🏠 Home",
    "🎮 Games",
    "🛡 Guards",
    "🕵 Detective",
    "🌾 Farming",
    "💎 VIP",
    "🖥 Display",
    "⚙ Settings"
}

for _,Name in ipairs(Tabs) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,0,42)
    Button.Text = Name
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 15
    Button.TextColor3 = Color3.new(1,1,1)
    Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Button.BorderSizePixel = 0
    Button.Parent = Sidebar

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0,8)
    C.Parent = Button
end

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0,210,0,65)
Content.Size = UDim2.new(1,-220,1,-75)
Content.BackgroundTransparency = 1
Content.Parent = Window

local Welcome = Instance.new("TextLabel")
Welcome.BackgroundTransparency = 1
Welcome.Size = UDim2.new(1,0,0,40)
Welcome.Font = Enum.Font.GothamBold
Welcome.TextSize = 28
Welcome.TextColor3 = Color3.new(1,1,1)
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.Text = "Welcome to SquidNoMo"
Welcome.Parent = Content

local Floating = Instance.new("TextButton")
Floating.Visible = false
Floating.Size = UDim2.fromOffset(58,58)
Floating.Position = UDim2.new(1,-75,1,-90)
Floating.Text = "🦑"
Floating.Font = Enum.Font.GothamBold
Floating.TextSize = 26
Floating.BackgroundColor3 = Color3.fromRGB(91,255,98)
Floating.TextColor3 = Color3.new(0,0,0)
Floating.BorderSizePixel = 0
Floating.Parent = Gui

local FC = Instance.new("UICorner")
FC.CornerRadius = UDim.new(1,0)
FC.Parent = Floating

Hide.MouseButton1Click:Connect(function()
    Window.Visible = false
    Floating.Visible = true
end)

Floating.MouseButton1Click:Connect(function()
    Floating.Visible = false
    Window.Visible = true
end)

print("SquidNoMo Milestone 1 Loaded")
