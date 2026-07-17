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
Title.Text = "SquidNoMo"
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
Minimize.Text = "-"
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
Floating.Text = "SQ"
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

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0.20,0,0.085,0)
Content.Size = UDim2.new(0.80,0,0.915,0)
Content.BackgroundTransparency = 1
Content.Parent = Window

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
    {"","Home"},
    {"","Games"},
    {"","Guards"},
    {"","Detective"},
    {"","Farming"},
    {"","VIP"},
    {"","Display"},
    {"","Settings"}
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

local HomePage = Instance.new("Frame")
--------------------------------------------------
-- HOME PAGE (PART 1)
--------------------------------------------------

local HomePage = Instance.new("ScrollingFrame")
HomePage.Name = "HomePage"
HomePage.Parent = Content
HomePage.BackgroundTransparency = 1
HomePage.BorderSizePixel = 0
HomePage.Position = UDim2.new(0,0,0,0)
HomePage.Size = UDim2.new(1,0,1,0)
HomePage.ScrollBarThickness = 4
HomePage.AutomaticCanvasSize = Enum.AutomaticSize.Y
HomePage.CanvasSize = UDim2.new(0,0,0,0)

local HomePadding = Instance.new("UIPadding")
HomePadding.Parent = HomePage
HomePadding.PaddingTop = UDim.new(0,20)
HomePadding.PaddingBottom = UDim.new(0,20)
HomePadding.PaddingLeft = UDim.new(0,20)
HomePadding.PaddingRight = UDim.new(0,20)

local HomeLayout = Instance.new("UIListLayout")
HomeLayout.Parent = HomePage
HomeLayout.Padding = UDim.new(0,18)
HomeLayout.SortOrder = Enum.SortOrder.LayoutOrder

--------------------------------------------------
-- HERO CARD
--------------------------------------------------

local Hero = Instance.new("Frame")
Hero.Parent = HomePage
Hero.LayoutOrder = 1
Hero.Size = UDim2.new(1,0,0,220)
Hero.BackgroundColor3 = Color3.fromRGB(38,38,38)
Hero.BorderSizePixel = 0

local HeroCorner = Instance.new("UICorner")
HeroCorner.CornerRadius = UDim.new(0,18)
HeroCorner.Parent = Hero

local HeroStroke = Instance.new("UIStroke")
HeroStroke.Parent = Hero
HeroStroke.Color = Color3.fromRGB(91,255,98)
HeroStroke.Thickness = 2

local HeroTitle = Instance.new("TextLabel")
HeroTitle.Parent = Hero
HeroTitle.BackgroundTransparency = 1
HeroTitle.Position = UDim2.new(0,20,0,18)
HeroTitle.Size = UDim2.new(.55,0,0,35)
HeroTitle.Font = Enum.Font.GothamBold
HeroTitle.Text = "Welcome to SquidNoMo!"
HeroTitle.TextColor3 = Color3.new(1,1,1)
HeroTitle.TextSize = 28
HeroTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeroBody = Instance.new("TextLabel")
HeroBody.Parent = Hero
HeroBody.BackgroundTransparency = 1
HeroBody.Position = UDim2.new(0,20,0,60)
HeroBody.Size = UDim2.new(.55,-10,0,135)
HeroBody.Font = Enum.Font.Gotham
HeroBody.TextWrapped = true
HeroBody.TextYAlignment = Enum.TextYAlignment.Top
HeroBody.TextXAlignment = Enum.TextXAlignment.Left
HeroBody.TextColor3 = Color3.fromRGB(225,225,225)
HeroBody.TextSize = 16
HeroBody.Text =
"SquidNoMo is the ultimate all-in-one companion for the Roblox experience \"Squid Game X\", bringing powerful features together in one clean, easy-to-use interface.\n\nUse the navigation menu on the left to access every available feature."

--------------------------------------------------
-- HERO IMAGE
--------------------------------------------------

local HeroImage = Instance.new("ImageLabel")
HeroImage.Parent = Hero
HeroImage.BackgroundTransparency = 1
HeroImage.AnchorPoint = Vector2.new(1,.5)
HeroImage.Position = UDim2.new(1,-20,.5,0)
HeroImage.Size = UDim2.new(0,180,0,180)
HeroImage.ScaleType = Enum.ScaleType.Fit

-- Replace later
HeroImage.Image = "rbxassetid://0"

local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(0,16)
ImageCorner.Parent = HeroImage

--------------------------------------------------
-- SECOND ROW
--------------------------------------------------

local Row2 = Instance.new("Frame")
Row2.Parent = HomePage
Row2.LayoutOrder = 2
Row2.BackgroundTransparency = 1
Row2.Size = UDim2.new(1,0,0,140)

local RowLayout = Instance.new("UIListLayout")
RowLayout.Parent = Row2
RowLayout.FillDirection = Enum.FillDirection.Horizontal
RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
RowLayout.Padding = UDim.new(0,16)

--------------------------------------------------
-- VERSION CARD
--------------------------------------------------

local VersionCard = Instance.new("Frame")
VersionCard.Parent = Row2
VersionCard.Size = UDim2.new(.5,-8,1,0)
VersionCard.BackgroundColor3 = Color3.fromRGB(38,38,38)
VersionCard.BorderSizePixel = 0

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0,18)
VersionCorner.Parent = VersionCard

local VersionStroke = Instance.new("UIStroke")
VersionStroke.Parent = VersionCard
VersionStroke.Color = Color3.fromRGB(170,120,255)
VersionStroke.Thickness = 2

local VersionTitle = Instance.new("TextLabel")
VersionTitle.Parent = VersionCard
VersionTitle.BackgroundTransparency = 1
VersionTitle.Position = UDim2.new(0,15,0,12)
VersionTitle.Size = UDim2.new(1,-30,0,24)
VersionTitle.Font = Enum.Font.GothamBold
VersionTitle.Text = "Version"
VersionTitle.TextColor3 = Color3.new(1,1,1)
VersionTitle.TextSize = 20
VersionTitle.TextXAlignment = Enum.TextXAlignment.Left

local VersionNumber = Instance.new("TextLabel")
VersionNumber.Parent = VersionCard
VersionNumber.BackgroundTransparency = 1
VersionNumber.Position = UDim2.new(0,15,0,48)
VersionNumber.Size = UDim2.new(1,-30,0,36)
VersionNumber.Font = Enum.Font.GothamBold
VersionNumber.Text = "v0.0.1"
VersionNumber.TextColor3 = Color3.fromRGB(170,120,255)
VersionNumber.TextSize = 30
VersionNumber.TextXAlignment = Enum.TextXAlignment.Left

local BuildLabel = Instance.new("TextLabel")
BuildLabel.Parent = VersionCard
BuildLabel.BackgroundTransparency = 1
BuildLabel.Position = UDim2.new(0,15,0,92)
BuildLabel.Size = UDim2.new(1,-30,0,20)
BuildLabel.Font = Enum.Font.Gotham
BuildLabel.Text = "Build 1"
BuildLabel.TextColor3 = Color3.fromRGB(220,220,220)
BuildLabel.TextSize = 15
BuildLabel.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------
-- SERVER CARD
--------------------------------------------------

local StatsService = game:GetService("Stats")

local ServerCard = Instance.new("Frame")
ServerCard.Parent = Row2
ServerCard.Size = UDim2.new(.5,-8,1,0)
ServerCard.BackgroundColor3 = Color3.fromRGB(38,38,38)
ServerCard.BorderSizePixel = 0

local ServerCorner = Instance.new("UICorner")
ServerCorner.CornerRadius = UDim.new(0,18)
ServerCorner.Parent = ServerCard

local ServerStroke = Instance.new("UIStroke")
ServerStroke.Parent = ServerCard
ServerStroke.Color = Color3.fromRGB(91,255,98)
ServerStroke.Thickness = 2

local ServerTitle = Instance.new("TextLabel")
ServerTitle.Parent = ServerCard
ServerTitle.BackgroundTransparency = 1
ServerTitle.Position = UDim2.new(0,15,0,12)
ServerTitle.Size = UDim2.new(1,-30,0,24)
ServerTitle.Font = Enum.Font.GothamBold
ServerTitle.Text = "Server"
ServerTitle.TextColor3 = Color3.new(1,1,1)
ServerTitle.TextSize = 20
ServerTitle.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new("Frame")
StatusDot.Parent = ServerCard
StatusDot.Size = UDim2.new(0,10,0,10)
StatusDot.Position = UDim2.new(0,18,0,48)
StatusDot.BackgroundColor3 = Color3.fromRGB(91,255,98)
StatusDot.BorderSizePixel = 0

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1,0)
DotCorner.Parent = StatusDot

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ServerCard
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0,35,0,42)
StatusLabel.Size = UDim2.new(.6,0,0,20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Online"
StatusLabel.TextColor3 = Color3.fromRGB(225,225,225)
StatusLabel.TextSize = 15
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = ServerCard
PingLabel.BackgroundTransparency = 1
PingLabel.Position = UDim2.new(0,18,0,72)
PingLabel.Size = UDim2.new(1,-30,0,20)
PingLabel.Font = Enum.Font.Gotham
PingLabel.Text = "Ping: -- ms"
PingLabel.TextColor3 = Color3.fromRGB(220,220,220)
PingLabel.TextSize = 15
PingLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayersLabel = Instance.new("TextLabel")
PlayersLabel.Parent = ServerCard
PlayersLabel.BackgroundTransparency = 1
PlayersLabel.Position = UDim2.new(0,18,0,95)
PlayersLabel.Size = UDim2.new(1,-30,0,20)
PlayersLabel.Font = Enum.Font.Gotham
PlayersLabel.Text = "Players: "..#Players:GetPlayers().." / "..Players.MaxPlayers
PlayersLabel.TextColor3 = Color3.fromRGB(220,220,220)
PlayersLabel.TextSize = 15
PlayersLabel.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	while task.wait(1) do

		PlayersLabel.Text =
			"Players: "..#Players:GetPlayers().." / "..Players.MaxPlayers

		pcall(function()
	local pingItem = StatsService.Network.ServerStatsItem["Data Ping"]
	if pingItem then
		PingLabel.Text = "Ping: "..math.floor(pingItem:GetValue()).." ms"
	end
end)

--------------------------------------------------
-- LATEST CHANGES CARD
--------------------------------------------------

local ChangesCard = Instance.new("Frame")
ChangesCard.Parent = HomePage
ChangesCard.LayoutOrder = 3
ChangesCard.Size = UDim2.new(1,0,0,250)
ChangesCard.BackgroundColor3 = Color3.fromRGB(38,38,38)
ChangesCard.BorderSizePixel = 0

local ChangesCorner = Instance.new("UICorner")
ChangesCorner.CornerRadius = UDim.new(0,18)
ChangesCorner.Parent = ChangesCard

local ChangesStroke = Instance.new("UIStroke")
ChangesStroke.Parent = ChangesCard
ChangesStroke.Color = Color3.fromRGB(75,170,255)
ChangesStroke.Thickness = 2

local ChangesTitle = Instance.new("TextLabel")
ChangesTitle.Parent = ChangesCard
ChangesTitle.BackgroundTransparency = 1
ChangesTitle.Position = UDim2.new(0,20,0,15)
ChangesTitle.Size = UDim2.new(1,-40,0,30)
ChangesTitle.Font = Enum.Font.GothamBold
ChangesTitle.Text = "Latest Changes"
ChangesTitle.TextSize = 22
ChangesTitle.TextColor3 = Color3.new(1,1,1)
ChangesTitle.TextXAlignment = Enum.TextXAlignment.Left

local Updates = {

	"Home Dashboard completely redesigned",

	"Responsive scaling improvements",

	"Floating launcher added",

	"Draggable floating launcher",

	"Smooth minimize animation",

	"Modern UI framework",

	"Cleaner sidebar",

	"Optimized for Delta Mobile",

	"Preparing for Settings page"

}

for i,v in ipairs(Updates) do

	local Bullet = Instance.new("TextLabel")
	Bullet.Parent = ChangesCard
	Bullet.BackgroundTransparency = 1
	Bullet.Position = UDim2.new(0,25,0,45+(i*20))
	Bullet.Size = UDim2.new(1,-40,0,18)
	Bullet.Font = Enum.Font.Gotham
	Bullet.Text = "• "..v
	Bullet.TextSize = 15
	Bullet.TextColor3 = Color3.fromRGB(225,225,225)
	Bullet.TextXAlignment = Enum.TextXAlignment.Left

end

--------------------------------------------------
-- FOOTER
--------------------------------------------------

local Footer = Instance.new("TextLabel")
Footer.Parent = HomePage
Footer.LayoutOrder = 4
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1,0,0,45)
Footer.Font = Enum.Font.GothamBold
Footer.Text = "❤ Thank you for using SquidNoMo!"
Footer.TextSize = 18
Footer.TextColor3 = Color3.fromRGB(235,235,235)
Footer.TextXAlignment = Enum.TextXAlignment.Center

--------------------------------------------------
-- SPACING FIX
--------------------------------------------------

HomeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

	HomePage.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			HomeLayout.AbsoluteContentSize.Y + 20
		)

end)

HomePage.CanvasSize =
	UDim2.new(
		0,
		0,
		0,
		HomeLayout.AbsoluteContentSize.Y + 20
)

--------------------------------------------------
-- FINAL POLISH
--------------------------------------------------

-- Hero Image Border
local HeroImageStroke = Instance.new("UIStroke")
HeroImageStroke.Parent = HeroImage
HeroImageStroke.Color = Color3.fromRGB(91,255,98)
HeroImageStroke.Thickness = 2

-- Hero Image Background
local HeroBackground = Instance.new("Frame")
HeroBackground.Parent = Hero
HeroBackground.AnchorPoint = Vector2.new(1,.5)
HeroBackground.Position = HeroImage.Position
HeroBackground.Size = UDim2.new(0,190,0,190)
HeroBackground.BackgroundColor3 = Color3.fromRGB(30,30,30)
HeroBackground.BorderSizePixel = 0
HeroBackground.ZIndex = HeroImage.ZIndex - 1

local HeroBGCorner = Instance.new("UICorner")
HeroBGCorner.CornerRadius = UDim.new(0,18)
HeroBGCorner.Parent = HeroBackground

--------------------------------------------------
-- CARD GRADIENTS
--------------------------------------------------

local function AddGradient(Frame)

	local Gradient = Instance.new("UIGradient")
	Gradient.Parent = Frame

	Gradient.Color = ColorSequence.new{

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(45,45,45)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(30,30,30)
		)

	}

	Gradient.Rotation = 90

end

AddGradient(Hero)
AddGradient(VersionCard)
AddGradient(ServerCard)
AddGradient(ChangesCard)

--------------------------------------------------
-- CARD PADDING
--------------------------------------------------

local function AddPadding(Frame)

	local Padding = Instance.new("UIPadding")
	Padding.Parent = Frame

	Padding.PaddingLeft = UDim.new(0,8)
	Padding.PaddingRight = UDim.new(0,8)
	Padding.PaddingTop = UDim.new(0,8)
	Padding.PaddingBottom = UDim.new(0,8)

end

AddPadding(VersionCard)
AddPadding(ServerCard)
AddPadding(ChangesCard)

--------------------------------------------------
-- HEADER DIVIDER
--------------------------------------------------

local Divider = Instance.new("Frame")
Divider.Parent = ChangesCard
Divider.Position = UDim2.new(0,18,0,46)
Divider.Size = UDim2.new(1,-36,0,1)
Divider.BorderSizePixel = 0
Divider.BackgroundColor3 = Color3.fromRGB(70,70,70)

--------------------------------------------------
-- HERO SUBTITLE
--------------------------------------------------

local HeroSubtitle = Instance.new("TextLabel")
HeroSubtitle.Parent = Hero
HeroSubtitle.BackgroundTransparency = 1
HeroSubtitle.Position = UDim2.new(0,20,0,190)
HeroSubtitle.Size = UDim2.new(.55,0,0,18)
HeroSubtitle.Font = Enum.Font.GothamBold
HeroSubtitle.Text = "Squid Game X • All-In-One Tool"
HeroSubtitle.TextColor3 = Color3.fromRGB(91,255,98)
HeroSubtitle.TextSize = 14
HeroSubtitle.TextXAlignment = Enum.TextXAlignment.Left

--------------------------------------------------
-- FOOTER COLOR
--------------------------------------------------

Footer.TextColor3 = Color3.fromRGB(180,180,180)

--------------------------------------------------
-- HOME PAGE READY
--------------------------------------------------

print("Home Dashboard Loaded")

print("Milestone 1 Loaded")

local TweenInfoFast = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

Minimize.MouseButton1Click:Connect(function()

    local Tween = TweenService:Create(
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
)

Tween:Play()
Tween.Completed:Wait()

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
