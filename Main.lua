repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
Window.Position = UDim2.new(0.5, 0, 0.55, 0)
Window.Size = UDim2.new(0.88,0,0.82,0)
Window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Window.BorderSizePixel = 0
Window.Parent = Gui

local OriginalSize = Window.Size

local UIScale = Instance.new("UIScale")
UIScale.Parent = Window

local function UpdateScale()
    local Camera = workspace.CurrentCamera
    if not Camera then return end

    local X = Camera.ViewportSize.X

    if X < 700 then
        UIScale.Scale = 0.82
    elseif X < 1000 then
        UIScale.Scale = 0.92
    else
        UIScale.Scale = 1
    end
end

UpdateScale()

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Window

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0.085,0)
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
Title.TextScaled = true

local TitleConstraint = Instance.new("UITextSizeConstraint")
TitleConstraint.MinTextSize = 16
TitleConstraint.MaxTextSize = 28
TitleConstraint.Parent = Title
Title.TextColor3 = Color3.fromRGB(91,255,98)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.new(1,-95,0,0)
Version.Size = UDim2.new(0,55,1,0)
Version.Font = Enum.Font.Gotham
Version.Text = "v0.0.1"
Version.TextScaled = true

local VersionConstraint = Instance.new("UITextSizeConstraint")
VersionConstraint.MinTextSize = 10
VersionConstraint.MaxTextSize = 16
VersionConstraint.Parent = Version
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

local Floating = Instance.new("TextButton")
Floating.Name = "Floating"
Floating.Visible = false
Floating.Size = UDim2.fromOffset(60,60)
Floating.AnchorPoint = Vector2.new(1,1)
Floating.Position = UDim2.new(1,-20,1,-20)
Floating.BackgroundColor3 = Color3.fromRGB(91,255,98)
Floating.Text = "🦑"
Floating.Font = Enum.Font.GothamBold
Floating.TextScaled = true
Floating.TextColor3 = Color3.new(0,0,0)
Floating.BorderSizePixel = 0
Floating.Parent = Gui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1,0)
FloatCorner.Parent = Floating

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.new(0,0,0.085,0)
Sidebar.Size = UDim2.new(0.20,0,0.915,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(35,35,35)
Sidebar.BorderSizePixel = 0
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.CanvasSize = UDim2.new()
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
Sidebar.Parent = Window

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0,10)
SideCorner.Parent = Sidebar

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Sidebar

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,8)
Padding.PaddingBottom = UDim.new(0,8)
Padding.PaddingLeft = UDim.new(0,10)
Padding.PaddingRight = UDim.new(0,10)
Padding.Parent = Sidebar

local Pages = {
    {"🏠","Home"},
    {"🎮","Games"},
    {"🛡","Guards"},
    {"🕵","Detective"},
    {"🌾","Farming"},
    {"💎","VIP"},
    {"🖥","Display"},
    {"⚙","Settings"}
}

for i,v in ipairs(Pages) do

    local Button = Instance.new("TextButton")
    Button.Name = v[2]
    Button.Size = UDim2.new(0.90,0,0,36)
    Button.LayoutOrder = i
    Button.BackgroundColor3 = i == 1
        and Color3.fromRGB(91,255,98)
        or Color3.fromRGB(48,48,48)

    Button.TextColor3 = i == 1
        and Color3.new(0,0,0)
        or Color3.new(1,1,1)

    Button.Font = Enum.Font.GothamBold
    Button.TextScaled = true

local ButtonConstraint = Instance.new("UITextSizeConstraint")
ButtonConstraint.MinTextSize = 12
ButtonConstraint.MaxTextSize = 18
ButtonConstraint.Parent = Button
    Button.Text = v[1].." "..v[2]
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = true
    Button.Parent = Sidebar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

end

print("Milestone 1 Loaded")

local TweenInfoFast = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

Minimize.MouseButton1Click:Connect(function()

    TweenService:Create(
        Window,
        TweenInfoFast,
        {
            Size = UDim2.new(
                OriginalSize.X.Scale,
                0,
                0,
                0
            )
        }
    ):Play()

    task.wait(0.2)

    Window.Visible = false
    Window.Size = OriginalSize
    Floating.Visible = true
end)

--// Draggable Floating Button (Mobile Friendly)
local UIS = game:GetService("UserInputService")

local dragging = false
local moved = false
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart

	if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
		moved = true
	end

	Floating.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Floating.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		moved = false
		dragStart = input.Position
		startPos = Floating.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement
	) then
		update(input)
	end
end)

UIS.InputEnded:Connect(function(input)
	if dragging then
		dragging = false

		if not moved then
			Floating.Visible = false
			Window.Visible = true
		end
	end
end)
