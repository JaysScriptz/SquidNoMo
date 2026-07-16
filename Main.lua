repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    PlayerGui:WaitForChild("SquidNoMo"):Destroy()
end)

local App = {}

App.Version = "0.0.1"
App.Name = "🦑 SquidNoMo 🎯"
App.Game = "Squid Game X"

App.Theme = {

    Background = Color3.fromRGB(17,17,17),
    Surface = Color3.fromRGB(27,27,27),
    Card = Color3.fromRGB(34,34,34),

    Border = Color3.fromRGB(48,48,48),

    Primary = Color3.fromRGB(91,255,98),

    Warning = Color3.fromRGB(255,184,0),

    Danger = Color3.fromRGB(255,77,77),

    Text = Color3.new(1,1,1),

    Secondary = Color3.fromRGB(180,180,180)

}

App.Device = "Desktop"

do

    local Size = workspace.CurrentCamera.ViewportSize

    if UserInputService.TouchEnabled then

        if math.min(Size.X,Size.Y) < 700 then

            App.Device = "Phone"

        else

            App.Device = "Tablet"

        end

    else

        App.Device = "Desktop"

    end

end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquidNoMo"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

App.Gui = ScreenGui

------------------------------------------------------------
-- UI Library
------------------------------------------------------------

local UI = {}

function UI:Corner(Object,Radius)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,Radius or 12)
    Corner.Parent = Object

    return Corner

end

function UI:Stroke(Object,Color,Thickness)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or App.Theme.Border
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Object

    return Stroke

end

function UI:Padding(Object,P)

    local Padding = Instance.new("UIPadding")

    Padding.PaddingTop = UDim.new(0,P)
    Padding.PaddingBottom = UDim.new(0,P)
    Padding.PaddingLeft = UDim.new(0,P)
    Padding.PaddingRight = UDim.new(0,P)

    Padding.Parent = Object

end

function UI:Label(Parent,Text,Size,Bold)

    local Label = Instance.new("TextLabel")

    Label.BackgroundTransparency = 1
    Label.Size = Size or UDim2.new(1,0,0,30)

    Label.Font = Bold and Enum.Font.GothamBold or Enum.Font.Gotham

    Label.Text = Text or ""

    Label.TextColor3 = App.Theme.Text

    Label.TextSize = 16

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Parent

    return Label

end

function UI:Button(Parent,Text)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1,0,0,42)

    Button.BackgroundColor3 = App.Theme.Card

    Button.TextColor3 = App.Theme.Text

    Button.Font = Enum.Font.GothamBold

    Button.TextSize = 15

    Button.AutoButtonColor = false

    Button.Text = Text

    Button.Parent = Parent

    UI:Corner(Button,10)
    UI:Stroke(Button)

    return Button

end

_G.SquidNoMo = App

print("[SquidNoMo] Loaded Bootstrap")
print("[SquidNoMo] Device:",App.Device)
print("[SquidNoMo] Version:",App.Version)

------------------------------------------------------------
-- Splash
------------------------------------------------------------

local Splash = Instance.new("Frame")
Splash.Name = "Splash"
Splash.Size = UDim2.fromScale(1,1)
Splash.BackgroundColor3 = App.Theme.Background
Splash.BorderSizePixel = 0
Splash.Parent = ScreenGui

local SplashTitle = UI:Label(
    Splash,
    "🦑 SquidNoMo 🎯",
    UDim2.new(1,0,0,60),
    true
)

SplashTitle.AnchorPoint = Vector2.new(.5,.5)
SplashTitle.Position = UDim2.new(.5,0,.40,0)
SplashTitle.TextXAlignment = Enum.TextXAlignment.Center
SplashTitle.TextSize = 34
SplashTitle.TextColor3 = App.Theme.Primary

local Status = UI:Label(
    Splash,
    "Initializing...",
    UDim2.new(1,0,0,25)
)

Status.AnchorPoint = Vector2.new(.5,.5)
Status.Position = UDim2.new(.5,0,.50,0)
Status.TextXAlignment = Enum.TextXAlignment.Center

local BarBack = Instance.new("Frame")
BarBack.Size = UDim2.fromOffset(320,8)
BarBack.AnchorPoint = Vector2.new(.5,.5)
BarBack.Position = UDim2.new(.5,0,.58,0)
BarBack.BackgroundColor3 = App.Theme.Card
BarBack.BorderSizePixel = 0
BarBack.Parent = Splash

UI:Corner(BarBack,100)

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = App.Theme.Primary
Bar.BorderSizePixel = 0
Bar.Parent = BarBack

UI:Corner(Bar,100)

TweenService:Create(
    Bar,
    TweenInfo.new(1.2,Enum.EasingStyle.Quad),
    {
        Size = UDim2.new(1,0,1,0)
    }
):Play()

------------------------------------------------------------
-- Main Window
------------------------------------------------------------

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Visible = false

if App.Device == "Phone" then

    Window.Size = UDim2.new(.92,0,.82,0)

elseif App.Device == "Tablet" then

    Window.Size = UDim2.new(.78,0,.80,0)

else

    Window.Size = UDim2.fromOffset(1100,680)

end

Window.AnchorPoint = Vector2.new(.5,.5)
Window.Position = UDim2.new(.5,0,.5,0)

Window.BackgroundColor3 = App.Theme.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

UI:Corner(Window,16)
UI:Stroke(Window)

------------------------------------------------------------
-- Header
------------------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60)
Header.BackgroundColor3 = App.Theme.Surface
Header.BorderSizePixel = 0
Header.Parent = Window

UI:Corner(Header,16)

local Title = UI:Label(
    Header,
    "🦑 SquidNoMo 🎯",
    UDim2.new(0,300,1,0),
    true
)

Title.Position = UDim2.fromOffset(20,0)
Title.TextColor3 = App.Theme.Primary
Title.TextSize = 24

local Experience = UI:Label(
    Header,
    "Experience : Squid Game X",
    UDim2.new(0,280,0,20)
)

Experience.Position = UDim2.new(1,-290,0,6)

local Detect = UI:Label(
    Header,
    "Status : Detecting...",
    UDim2.new(0,280,0,20)
)

Detect.Position = UDim2.new(1,-290,0,24)
Detect.TextColor3 = App.Theme.Primary

------------------------------------------------------------
-- Splash Finish
------------------------------------------------------------

task.delay(1.5,function()

    Splash:Destroy()

    Window.Visible = true

end)

App.Window = Window
App.Header = Header

print("[SquidNoMo] Window Created")

------------------------------------------------------------
-- Sidebar
------------------------------------------------------------

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0,210,1,-60)
Sidebar.Position = UDim2.new(0,0,0,60)
Sidebar.BackgroundColor3 = App.Theme.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

UI:Stroke(Sidebar)

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0,8)
List.FillDirection = Enum.FillDirection.Vertical
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Sidebar

local Pad = Instance.new("UIPadding")
Pad.PaddingTop = UDim.new(0,15)
Pad.PaddingLeft = UDim.new(0,10)
Pad.PaddingRight = UDim.new(0,10)
Pad.Parent = Sidebar

------------------------------------------------------------
-- Content
------------------------------------------------------------

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0,220,0,70)
Content.Size = UDim2.new(1,-235,1,-85)
Content.Parent = Window

------------------------------------------------------------
-- Home Page
------------------------------------------------------------

local Home = Instance.new("ScrollingFrame")
Home.Name = "Home"
Home.Size = UDim2.new(1,0,1,0)
Home.BackgroundTransparency = 1
Home.BorderSizePixel = 0
Home.ScrollBarThickness = 4
Home.CanvasSize = UDim2.new(0,0,0,900)
Home.Parent = Content

local HomeLayout = Instance.new("UIListLayout")
HomeLayout.Padding = UDim.new(0,12)
HomeLayout.Parent = Home

------------------------------------------------------------
-- Welcome
------------------------------------------------------------

local Welcome = UI:Label(
    Home,
    "Welcome to SquidNoMo 🎯",
    UDim2.new(1,0,0,40),
    true
)

Welcome.TextSize = 28

------------------------------------------------------------
-- Helper
------------------------------------------------------------

local function CreateCard(TitleText,BodyText)

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1,-10,0,110)
    Card.BackgroundColor3 = App.Theme.Card
    Card.BorderSizePixel = 0
    Card.Parent = Home

    UI:Corner(Card,12)
    UI:Stroke(Card)

    UI:Padding(Card,15)

    local Title = UI:Label(
        Card,
        TitleText,
        UDim2.new(1,0,0,25),
        true
    )

    Title.TextSize = 18

    local Body = UI:Label(
        Card,
        BodyText,
        UDim2.new(1,0,1,-35)
    )

    Body.Position = UDim2.fromOffset(0,32)
    Body.TextWrapped = true
    Body.TextColor3 = App.Theme.Secondary

    return Card

end

------------------------------------------------------------
-- Cards
------------------------------------------------------------

CreateCard(
    "⚠ Warning",
    "Use SquidNoMo responsibly. By continuing you acknowledge that script usage may violate game rules and may result in moderation. The developer is not responsible for account actions."
)

CreateCard(
    "🎮 Experience",
    "Current Experience: Squid Game X\nDetection: Checking..."
)

CreateCard(
    "📱 Supported Devices",
    "Phone\nTablet\nDesktop"
)

CreateCard(
    "👤 Role",
    "Lobby\nConfiguration Mode"
)

CreateCard(
    "⚙ System",
    "Theme: Dark\nVersion: "..App.Version
)

------------------------------------------------------------
-- Sidebar Buttons
------------------------------------------------------------

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

App.Tabs = {}

for _,Name in ipairs(Tabs) do

    local Button = UI:Button(Sidebar,Name)

    table.insert(App.Tabs,Button)

end

App.Content = Content
App.Home = Home
App.Sidebar = Sidebar

print("[SquidNoMo] Sidebar Loaded")

------------------------------------------------------------
-- Dragging
------------------------------------------------------------

local Dragging = false
local DragInput
local DragStart
local StartPos

local function UpdateDrag(Input)

	local Delta = Input.Position - DragStart

	Window.Position = UDim2.new(
		StartPos.X.Scale,
		StartPos.X.Offset + Delta.X,
		StartPos.Y.Scale,
		StartPos.Y.Offset + Delta.Y
	)

end

Header.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPos = Window.Position

		Input.Changed:Connect(function()

			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end

		end)

	end

end)

Header.InputChanged:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseMovement
	or Input.UserInputType == Enum.UserInputType.Touch then

		DragInput = Input

	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if Dragging and Input == DragInput then

		UpdateDrag(Input)

	end

end)

------------------------------------------------------------
-- Hide Button
------------------------------------------------------------

local HideButton = Instance.new("TextButton")
HideButton.Name = "Hide"

HideButton.Size = UDim2.fromOffset(34,34)
HideButton.Position = UDim2.new(1,-44,0,13)

HideButton.BackgroundColor3 = App.Theme.Card
HideButton.BorderSizePixel = 0

HideButton.Text = "—"
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 18
HideButton.TextColor3 = App.Theme.Text

HideButton.Parent = Header

UI:Corner(HideButton,8)
UI:Stroke(HideButton)

------------------------------------------------------------
-- Floating Button
------------------------------------------------------------

local Floating = Instance.new("TextButton")
Floating.Name = "Floating"

Floating.Visible = false

Floating.Size = UDim2.fromOffset(58,58)

Floating.Position = UDim2.new(
	1,
	-80,
	1,
	-120
)

Floating.BackgroundColor3 = App.Theme.Primary
Floating.BorderSizePixel = 0

Floating.Text = "🦑"
Floating.Font = Enum.Font.GothamBold
Floating.TextSize = 26
Floating.TextColor3 = Color3.new(0,0,0)

Floating.Parent = ScreenGui

UI:Corner(Floating,100)

------------------------------------------------------------
-- Hide / Show
------------------------------------------------------------

HideButton.MouseButton1Click:Connect(function()

	Window.Visible = false
	Floating.Visible = true

end)

Floating.MouseButton1Click:Connect(function()

	Window.Visible = true
	Floating.Visible = false

end)

------------------------------------------------------------
-- Floating Drag
------------------------------------------------------------

local FloatDrag = false
local FloatStart
local FloatInput
local FloatPos

Floating.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then

		FloatDrag = true

		FloatStart = Input.Position
		FloatPos = Floating.Position

		Input.Changed:Connect(function()

			if Input.UserInputState == Enum.UserInputState.End then
				FloatDrag = false
			end

		end)

	end

end)

Floating.InputChanged:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseMovement
	or Input.UserInputType == Enum.UserInputType.Touch then

		FloatInput = Input

	end

end)

UserInputService.InputChanged:Connect(function(Input)

	if FloatDrag and Input == FloatInput then

		local Delta = Input.Position - FloatStart

		Floating.Position = UDim2.new(
			FloatPos.X.Scale,
			FloatPos.X.Offset + Delta.X,
			FloatPos.Y.Scale,
			FloatPos.Y.Offset + Delta.Y
		)

	end

end)

------------------------------------------------------------
-- Startup Notification
------------------------------------------------------------

task.delay(2,function()

	print("[SquidNoMo] UI Ready")

end)

App.FloatingButton = Floating

