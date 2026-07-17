--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Main Application Loader
--//========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------
-- Destroy Existing UI
----------------------------------------------------------

local Existing = PlayerGui:FindFirstChild("SquidNoMo")

if Existing then
    Existing:Destroy()
end

----------------------------------------------------------
-- Core Modules
----------------------------------------------------------

local Core = script.Parent:WaitForChild("Core")

local Theme = require(Core.Theme)
local Components = require(Core.Components)
local Navigation = require(Core.Navigation)
local Notifications = require(Core.Notifications)

----------------------------------------------------------
-- Pages
----------------------------------------------------------

local Modules = script.Parent:WaitForChild("Modules")

local Home = require(Modules.Home)
local PlayersPage = require(Modules.Players)
local Guards = require(Modules.Guards)
local Detective = require(Modules.Detective)
local Farming = require(Modules.Farming)
local VIP = require(Modules.VIP)
local Games = require(Modules.Games)
local Settings = require(Modules.Settings)
local Support = require(Modules.Support)

----------------------------------------------------------
-- Application
----------------------------------------------------------

local App = {

    Name = "SquidNoMo",

    Version = "Beta 4.0",

    Build = "4.0.0",

    Pages = {},

    CurrentPage = nil,

    Theme = Theme,

    Components = Components,

    Navigation = Navigation,

    Notifications = Notifications

}
----------------------------------------------------------
-- ScreenGui
----------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = App.Name
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

----------------------------------------------------------
-- Root Window
----------------------------------------------------------

local Window = Instance.new("Frame")

Window.Name = "Window"
Window.AnchorPoint = Vector2.new(.5,.5)
Window.Position = UDim2.fromScale(.5,.5)
Window.Size = UDim2.fromOffset(1225,730)
Window.BackgroundColor3 = Theme.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0,18)
WindowCorner.Parent = Window

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Theme.Border
WindowStroke.Thickness = 1.3
WindowStroke.Parent = Window

----------------------------------------------------------
-- Window Shadow
----------------------------------------------------------

local WindowShadow = Instance.new("ImageLabel")

WindowShadow.Name = "Shadow"
WindowShadow.AnchorPoint = Vector2.new(.5,.5)
WindowShadow.Position = UDim2.fromScale(.5,.5)
WindowShadow.Size = UDim2.new(1,80,1,80)
WindowShadow.BackgroundTransparency = 1
WindowShadow.Image = "rbxassetid://1316045217"
WindowShadow.ImageTransparency = .45
WindowShadow.ScaleType = Enum.ScaleType.Slice
WindowShadow.SliceCenter = Rect.new(10,10,118,118)
WindowShadow.ZIndex = -1
WindowShadow.Parent = Window

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

local Sidebar = Instance.new("Frame")

Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(245,730)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0,18)
SidebarCorner.Parent = Sidebar

----------------------------------------------------------
-- Divider
----------------------------------------------------------

local Divider = Instance.new("Frame")

Divider.Name = "Divider"
Divider.Size = UDim2.fromOffset(1,730)
Divider.Position = UDim2.fromOffset(245,0)
Divider.BackgroundColor3 = Theme.Border
Divider.BackgroundTransparency = .75
Divider.BorderSizePixel = 0
Divider.Parent = Window

----------------------------------------------------------
-- Header
----------------------------------------------------------

local Header = Instance.new("Frame")

Header.Name = "Header"
Header.Size = UDim2.new(1,-245,0,72)
Header.Position = UDim2.fromOffset(246,0)
Header.BackgroundTransparency = 1
Header.Parent = Window

----------------------------------------------------------
-- Header Title
----------------------------------------------------------

local HeaderTitle = Instance.new("TextLabel")

HeaderTitle.Name = "PageTitle"
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Position = UDim2.fromOffset(24,18)
HeaderTitle.Size = UDim2.new(0,350,0,24)
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.Text = "Dashboard"
HeaderTitle.TextColor3 = Theme.Text
HeaderTitle.TextSize = 24
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

----------------------------------------------------------
-- Header Subtitle
----------------------------------------------------------

local HeaderSubtitle = Instance.new("TextLabel")

HeaderSubtitle.BackgroundTransparency = 1
HeaderSubtitle.Position = UDim2.fromOffset(24,44)
HeaderSubtitle.Size = UDim2.new(0,420,0,18)
HeaderSubtitle.Font = Enum.Font.Gotham
HeaderSubtitle.Text = "SquidNoMo Beta 4.0"
HeaderSubtitle.TextColor3 = Theme.SubText
HeaderSubtitle.TextSize = 13
HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderSubtitle.Parent = Header

----------------------------------------------------------
-- Header Right Container
----------------------------------------------------------

local HeaderRight = Instance.new("Frame")

HeaderRight.Name = "HeaderRight"
HeaderRight.AnchorPoint = Vector2.new(1,0)
HeaderRight.Position = UDim2.new(1,-20,0,16)
HeaderRight.Size = UDim2.fromOffset(260,42)
HeaderRight.BackgroundTransparency = 1
HeaderRight.Parent = Header

----------------------------------------------------------
-- Minimize Button
----------------------------------------------------------

local Minimize = Instance.new("TextButton")

Minimize.Name = "Minimize"
Minimize.AnchorPoint = Vector2.new(1,.5)
Minimize.Position = UDim2.new(1,0,.5,0)
Minimize.Size = UDim2.fromOffset(38,38)
Minimize.BackgroundColor3 = Theme.Card
Minimize.BorderSizePixel = 0
Minimize.Text = "—"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 20
Minimize.TextColor3 = Theme.Text
Minimize.AutoButtonColor = false
Minimize.Parent = HeaderRight

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,10)
MinCorner.Parent = Minimize

----------------------------------------------------------
-- Content Holder
----------------------------------------------------------

local Content = Instance.new("Frame")

Content.Name = "Content"
Content.Position = UDim2.fromOffset(262,84)
Content.Size = UDim2.new(1,-280,1,-102)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Window

----------------------------------------------------------
-- Register References
----------------------------------------------------------

App.Gui = ScreenGui
App.Window = Window
App.Sidebar = Sidebar
App.Header = Header
App.Content = Content
App.HeaderTitle = HeaderTitle
App.HeaderSubtitle = HeaderSubtitle

----------------------------------------------------------
-- Fade In
----------------------------------------------------------

Window.BackgroundTransparency = 1

TweenService:Create(
    Window,
    TweenInfo.new(.25, Enum.EasingStyle.Quint),
    {
        BackgroundTransparency = 0
    }
):Play()

----------------------------------------------------------
-- Sidebar Branding
----------------------------------------------------------

local Branding = Instance.new("Frame")
Branding.Name = "Branding"
Branding.Size = UDim2.new(1,0,0,90)
Branding.BackgroundTransparency = 1
Branding.Parent = Sidebar

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.fromOffset(46,46)
Logo.Position = UDim2.fromOffset(18,20)
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Image = "" --// SquidNoMo Logo Asset
Logo.Parent = Branding

local LogoGlow = Instance.new("UIStroke")
LogoGlow.Color = Theme.Border
LogoGlow.Thickness = 1.2
LogoGlow.Parent = Logo

local AppTitle = Instance.new("TextLabel")
AppTitle.BackgroundTransparency = 1
AppTitle.Position = UDim2.fromOffset(74,18)
AppTitle.Size = UDim2.new(1,-84,0,24)
AppTitle.Font = Enum.Font.GothamBold
AppTitle.Text = App.Name
AppTitle.TextColor3 = Theme.Text
AppTitle.TextSize = 24
AppTitle.TextXAlignment = Enum.TextXAlignment.Left
AppTitle.Parent = Branding

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(74,45)
Version.Size = UDim2.new(1,-84,0,16)
Version.Font = Enum.Font.Gotham
Version.Text = App.Version
Version.TextColor3 = Theme.SubText
Version.TextSize = 13
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Branding

----------------------------------------------------------
-- Navigation Holder
----------------------------------------------------------

local NavigationHolder = Instance.new("Frame")
NavigationHolder.Name = "Navigation"
NavigationHolder.BackgroundTransparency = 1
NavigationHolder.Position = UDim2.fromOffset(0,105)
NavigationHolder.Size = UDim2.new(1,0,1,-185)
NavigationHolder.Parent = Sidebar

local NavigationLayout = Instance.new("UIListLayout")
NavigationLayout.Padding = UDim.new(0,8)
NavigationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavigationLayout.Parent = NavigationHolder

----------------------------------------------------------
-- Navigation Table
----------------------------------------------------------

App.NavigationButtons = {}

local NavigationItems = {

	{Name="Home",Title="Dashboard"},
	{Name="Players",Title="Players"},
	{Name="Guards",Title="Guards"},
	{Name="Detective",Title="Detective"},
	{Name="Farming",Title="Farming"},
	{Name="VIP",Title="VIP"},
	{Name="Games",Title="Games"},
	{Name="Settings",Title="Settings"},
	{Name="Support",Title="Support Development"}

}

----------------------------------------------------------
-- Navigation Button Builder
----------------------------------------------------------

local function CreateNavigationButton(Data)

	local Button = Instance.new("TextButton")

	Button.Name = Data.Name

	Button.Size = UDim2.new(.90,0,0,44)

	Button.BackgroundColor3 = Theme.Card

	Button.AutoButtonColor = false

	Button.Text = ""

	Button.Parent = NavigationHolder

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(50,50,50)
	Stroke.Parent = Button

	local Indicator = Instance.new("Frame")
	Indicator.Visible = false
	Indicator.Size = UDim2.fromOffset(4,28)
	Indicator.Position = UDim2.new(0,8,.5,-14)
	Indicator.BackgroundColor3 = Theme.Accent
	Indicator.BorderSizePixel = 0
	Indicator.Parent = Button

	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(1,0)
	IndicatorCorner.Parent = Indicator

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(22,0)
	Label.Size = UDim2.new(1,-30,1,0)
	Label.Font = Enum.Font.GothamSemibold
	Label.Text = Data.Title
	Label.TextColor3 = Theme.SubText
	Label.TextSize = 14
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Button

	Button.MouseEnter:Connect(function()

		if App.CurrentPage ~= Data.Name then

			TweenService:Create(
				Button,
				TweenInfo.new(.18),
				{
					BackgroundColor3 = Color3.fromRGB(36,36,36)
				}
			):Play()

		end

	end)

	Button.MouseLeave:Connect(function()

		if App.CurrentPage ~= Data.Name then

			TweenService:Create(
				Button,
				TweenInfo.new(.18),
				{
					BackgroundColor3 = Theme.Card
				}
			):Play()

		end

	end)

	Button.MouseButton1Click:Connect(function()

		App.Navigation:SwitchPage(Data.Name)

	end)

	App.NavigationButtons[Data.Name] = {

		Button = Button,

		Label = Label,

		Indicator = Indicator,

		Stroke = Stroke

	}

end

----------------------------------------------------------
-- Create Navigation
----------------------------------------------------------

for _,Item in ipairs(NavigationItems) do

	CreateNavigationButton(Item)

end

----------------------------------------------------------
-- Sidebar Footer
----------------------------------------------------------

local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1,0,0,62)
Footer.Position = UDim2.new(0,0,1,-70)
Footer.Parent = Sidebar

local FooterLabel = Instance.new("TextLabel")
FooterLabel.BackgroundTransparency = 1
FooterLabel.Size = UDim2.new(1,0,1,0)
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.Text = "SquidNoMo • Beta 4.0"
FooterLabel.TextColor3 = Theme.SubText
FooterLabel.TextSize = 12
FooterLabel.Parent = Footer

----------------------------------------------------------
-- Finish
----------------------------------------------------------

App.NavigationHolder = NavigationHolder
