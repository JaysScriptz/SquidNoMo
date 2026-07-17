--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Main.lua
--// Application Bootstrap
--//========================================================--

----------------------------------------------------------
-- Services
----------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

----------------------------------------------------------
-- Destroy Existing GUI
----------------------------------------------------------

local Existing = PlayerGui:FindFirstChild("SquidNoMo")

if Existing then
	Existing:Destroy()
end

----------------------------------------------------------
-- Core Modules
----------------------------------------------------------

local CoreFolder = script:WaitForChild("Core")

local Theme = require(CoreFolder.Theme)
local Components = require(CoreFolder.Components)
local Navigation = require(CoreFolder.Navigation)
local Notifications = require(CoreFolder.Notifications)
local Utilities = require(CoreFolder.Utilities)

----------------------------------------------------------
-- Page Modules
----------------------------------------------------------

local ModuleFolder = script:WaitForChild("Modules")

local Home = require(ModuleFolder.Home)
local PlayersPage = require(ModuleFolder.Players)
local Guards = require(ModuleFolder.Guards)
local Detective = require(ModuleFolder.Detective)
local Farming = require(ModuleFolder.Farming)
local VIP = require(ModuleFolder.VIP)
local Games = require(ModuleFolder.Games)
local Settings = require(ModuleFolder.Settings)
local Support = require(ModuleFolder.Support)

----------------------------------------------------------
-- Application Table
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

	Notifications = Notifications,

	Utilities = Utilities

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

App.Gui = ScreenGui

----------------------------------------------------------
-- Main Window
----------------------------------------------------------

local Window = Instance.new("Frame")

Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.fromScale(0.5,0.5)
Window.Size = UDim2.fromOffset(
	Theme.WindowWidth,
	Theme.WindowHeight
)
Window.BackgroundColor3 = Theme.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0,Theme.CardRadius)
WindowCorner.Parent = Window

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Theme.BorderDark
WindowStroke.Thickness = 1
WindowStroke.Parent = Window

----------------------------------------------------------
-- Shadow
----------------------------------------------------------

local Shadow = Instance.new("ImageLabel")

Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(.5,.5)
Shadow.Position = UDim2.fromScale(.5,.5)
Shadow.Size = UDim2.new(1,90,1,90)
Shadow.BackgroundTransparency = 1
Shadow.Image = Theme.Assets.Shadow
Shadow.ImageTransparency = .45
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10,10,118,118)
Shadow.ZIndex = -1
Shadow.Parent = Window

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

local Sidebar = Instance.new("Frame")

Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(
	Theme.SidebarWidth,
	Theme.WindowHeight
)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Window

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0,Theme.CardRadius)
SidebarCorner.Parent = Sidebar

----------------------------------------------------------
-- Divider
----------------------------------------------------------

local Divider = Instance.new("Frame")

Divider.Name = "Divider"
Divider.Position = UDim2.fromOffset(
	Theme.SidebarWidth,
	0
)
Divider.Size = UDim2.fromOffset(
	1,
	Theme.WindowHeight
)
Divider.BackgroundColor3 = Theme.BorderDark
Divider.BorderSizePixel = 0
Divider.Parent = Window

----------------------------------------------------------
-- Header
----------------------------------------------------------

local Header = Instance.new("Frame")

Header.Name = "Header"
Header.Position = UDim2.fromOffset(
	Theme.SidebarWidth + 1,
	0
)

Header.Size = UDim2.new(
	1,
	-(Theme.SidebarWidth + 1),
	0,
	Theme.HeaderHeight
)

Header.BackgroundColor3 = Theme.Header
Header.BorderSizePixel = 0
Header.Parent = Window

----------------------------------------------------------
-- Header Title
----------------------------------------------------------

local HeaderTitle = Instance.new("TextLabel")

HeaderTitle.Name = "HeaderTitle"

HeaderTitle.BackgroundTransparency = 1

HeaderTitle.Position = UDim2.fromOffset(24,14)

HeaderTitle.Size = UDim2.new(0,400,0,24)

HeaderTitle.Font = Theme.FontBold

HeaderTitle.Text = "Dashboard"

HeaderTitle.TextSize = 22

HeaderTitle.TextColor3 = Theme.Text

HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

HeaderTitle.Parent = Header

----------------------------------------------------------
-- Header Subtitle
----------------------------------------------------------

local HeaderSubtitle = Instance.new("TextLabel")

HeaderSubtitle.BackgroundTransparency = 1

HeaderSubtitle.Position = UDim2.fromOffset(24,40)

HeaderSubtitle.Size = UDim2.new(0,420,0,18)

HeaderSubtitle.Font = Theme.Font

HeaderSubtitle.Text = Theme.Version

HeaderSubtitle.TextSize = 13

HeaderSubtitle.TextColor3 = Theme.SubText

HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left

HeaderSubtitle.Parent = Header

----------------------------------------------------------
-- Content Holder
----------------------------------------------------------

local Content = Instance.new("Frame")

Content.Name = "Content"

Content.BackgroundTransparency = 1

Content.Position = UDim2.fromOffset(
	Theme.SidebarWidth + Theme.PagePadding,
	Theme.HeaderHeight + Theme.PagePadding
)

Content.Size = UDim2.new(
	1,
	-(Theme.SidebarWidth + Theme.PagePadding * 2),
	1,
	-(Theme.HeaderHeight + Theme.PagePadding * 2)
)

Content.ClipsDescendants = true

Content.Parent = Window

----------------------------------------------------------
-- Save References
----------------------------------------------------------

App.Window = Window
App.Sidebar = Sidebar
App.Header = Header
App.Content = Content

App.HeaderTitle = HeaderTitle
App.HeaderSubtitle = HeaderSubtitle

----------------------------------------------------------
-- Initialize Notifications
----------------------------------------------------------

Notifications:Init(
	ScreenGui,
	Theme
)

----------------------------------------------------------
-- Sidebar Branding
----------------------------------------------------------

local Branding = Instance.new("Frame")
Branding.Name = "Branding"
Branding.BackgroundTransparency = 1
Branding.Size = UDim2.new(1,0,0,90)
Branding.Parent = Sidebar

local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.BackgroundTransparency = 1
Logo.Position = UDim2.fromOffset(20,20)
Logo.Size = UDim2.fromOffset(48,48)
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Image = Theme.Assets.Logo
Logo.Parent = Branding

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(78,18)
Title.Size = UDim2.new(1,-88,0,24)
Title.Font = Theme.FontBold
Title.Text = App.Name
Title.TextSize = 22
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Branding

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(78,44)
Version.Size = UDim2.new(1,-88,0,18)
Version.Font = Theme.Font
Version.Text = App.Version
Version.TextSize = 13
Version.TextColor3 = Theme.SubText
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Branding

----------------------------------------------------------
-- Navigation Holder
----------------------------------------------------------

local NavigationHolder = Instance.new("Frame")

NavigationHolder.Name = "Navigation"

NavigationHolder.BackgroundTransparency = 1

NavigationHolder.Position = UDim2.fromOffset(0,105)

NavigationHolder.Size = UDim2.new(1,0,1,-180)

NavigationHolder.Parent = Sidebar

local NavigationLayout = Instance.new("UIListLayout")

NavigationLayout.Padding = UDim.new(0,8)

NavigationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

NavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder

NavigationLayout.Parent = NavigationHolder

----------------------------------------------------------
-- Navigation Buttons
----------------------------------------------------------

App.NavigationButtons = {}

local Pages = {

	{"Home","Dashboard"},
	{"Players","Players"},
	{"Guards","Guards"},
	{"Detective","Detective"},
	{"Farming","Farming"},
	{"VIP","VIP"},
	{"Games","Games"},
	{"Settings","Settings"},
	{"Support","Support Development"}

}

local function CreateNavigationButton(PageName,Display)

	local Button = Instance.new("TextButton")

	Button.Name = PageName

	Button.Size = UDim2.new(.90,0,0,44)

	Button.BackgroundColor3 = Theme.Card

	Button.BorderSizePixel = 0

	Button.AutoButtonColor = false

	Button.Text = ""

	Button.Parent = NavigationHolder

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,10)

	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")

	Stroke.Color = Theme.BorderDark

	Stroke.Parent = Button

	local Indicator = Instance.new("Frame")

	Indicator.Visible = false

	Indicator.Size = UDim2.fromOffset(4,26)

	Indicator.Position = UDim2.new(0,8,.5,-13)

	Indicator.BackgroundColor3 = Theme.Accent

	Indicator.BorderSizePixel = 0

	Indicator.Parent = Button

	local IC = Instance.new("UICorner")

	IC.CornerRadius = UDim.new(1,0)

	IC.Parent = Indicator

	local Label = Instance.new("TextLabel")

	Label.BackgroundTransparency = 1

	Label.Position = UDim2.fromOffset(22,0)

	Label.Size = UDim2.new(1,-30,1,0)

	Label.Font = Theme.FontMedium

	Label.Text = Display

	Label.TextColor3 = Theme.SubText

	Label.TextSize = 14

	Label.TextXAlignment = Enum.TextXAlignment.Left

	Label.Parent = Button

	Button.MouseButton1Click:Connect(function()

		Navigation:Open(PageName,App)

	end)

	App.NavigationButtons[PageName] = {

		Button = Button,

		Label = Label,

		Indicator = Indicator

	}

end

for _,Info in ipairs(Pages) do

	CreateNavigationButton(Info[1],Info[2])

end

----------------------------------------------------------
-- Sidebar Footer
----------------------------------------------------------

local Footer = Instance.new("TextLabel")

Footer.BackgroundTransparency = 1

Footer.AnchorPoint = Vector2.new(.5,1)

Footer.Position = UDim2.new(.5,0,1,-14)

Footer.Size = UDim2.new(1,-20,0,18)

Footer.Font = Theme.Font

Footer.Text = "SquidNoMo • Beta 4.0"

Footer.TextSize = 12

Footer.TextColor3 = Theme.SubText

Footer.Parent = Sidebar

----------------------------------------------------------
-- Save References
----------------------------------------------------------

App.NavigationHolder = NavigationHolder

----------------------------------------------------------
-- Create Page Frames
----------------------------------------------------------

local function CreatePage(Name)

	local Frame = Instance.new("Frame")

	Frame.Name = Name

	Frame.BackgroundTransparency = 1

	Frame.Size = UDim2.fromScale(1,1)

	Frame.Visible = false

	Frame.Parent = Content

	return Frame

end

----------------------------------------------------------
-- Create Pages
----------------------------------------------------------

local HomePage = CreatePage("Home")

local PlayersPageFrame = CreatePage("Players")

local GuardsPage = CreatePage("Guards")

local DetectivePage = CreatePage("Detective")

local FarmingPage = CreatePage("Farming")

local VIPPage = CreatePage("VIP")

local GamesPage = CreatePage("Games")

local SettingsPage = CreatePage("Settings")

local SupportPage = CreatePage("Support")

----------------------------------------------------------
-- Register Pages
----------------------------------------------------------

Navigation:Register("Home",HomePage)

Navigation:Register("Players",PlayersPageFrame)

Navigation:Register("Guards",GuardsPage)

Navigation:Register("Detective",DetectivePage)

Navigation:Register("Farming",FarmingPage)

Navigation:Register("VIP",VIPPage)

Navigation:Register("Games",GamesPage)

Navigation:Register("Settings",SettingsPage)

Navigation:Register("Support",SupportPage)

----------------------------------------------------------
-- Initialize Modules
----------------------------------------------------------

Home:Create(HomePage,App)

PlayersPage:Create(PlayersPageFrame,App)

Guards:Create(GuardsPage,App)

Detective:Create(DetectivePage,App)

Farming:Create(FarmingPage,App)

VIP:Create(VIPPage,App)

Games:Create(GamesPage,App)

Settings:Create(SettingsPage,App)

Support:Create(SupportPage,App)

----------------------------------------------------------
-- Open Home
----------------------------------------------------------

Navigation:Open("Home",App)

----------------------------------------------------------
-- Notify
----------------------------------------------------------

Notifications:Success(

	"SquidNoMo",

	"Beta 4.0 Loaded Successfully",

	3

)

----------------------------------------------------------
-- Save Global App
----------------------------------------------------------

_G.SquidNoMo = App

----------------------------------------------------------
-- Enable Window Dragging
----------------------------------------------------------

Utilities:EnableDragging(
	Window,
	Header
)

----------------------------------------------------------
-- Minimize Button
----------------------------------------------------------

local Minimized = false

local MinimizeButton = Instance.new("TextButton")

MinimizeButton.Name = "Minimize"

MinimizeButton.AnchorPoint = Vector2.new(1,0.5)

MinimizeButton.Position = UDim2.new(1,-18,0.5,0)

MinimizeButton.Size = UDim2.fromOffset(34,34)

MinimizeButton.BackgroundColor3 = Theme.Card

MinimizeButton.BorderSizePixel = 0

MinimizeButton.Text = "—"

MinimizeButton.Font = Theme.FontBold

MinimizeButton.TextSize = 22

MinimizeButton.TextColor3 = Theme.Text

MinimizeButton.AutoButtonColor = false

MinimizeButton.Parent = Header

local MinCorner = Instance.new("UICorner")

MinCorner.CornerRadius = UDim.new(0,10)

MinCorner.Parent = MinimizeButton

MinimizeButton.MouseButton1Click:Connect(function()

	Minimized = not Minimized

	if Minimized then

		TweenService:Create(
			Content,
			Theme.NormalTween,
			{
				Size = UDim2.new(
					1,
					-(Theme.SidebarWidth + Theme.PagePadding * 2),
					0,
					0
				)
			}
		):Play()

	else

		TweenService:Create(
			Content,
			Theme.NormalTween,
			{
				Size = UDim2.new(
					1,
					-(Theme.SidebarWidth + Theme.PagePadding * 2),
					1,
					-(Theme.HeaderHeight + Theme.PagePadding * 2)
				)
			}
		):Play()

	end

end)

----------------------------------------------------------
-- Cleanup
----------------------------------------------------------

function App:Destroy()

	if self.Gui then

		self.Gui:Destroy()

	end

	_G.SquidNoMo = nil

end

----------------------------------------------------------
-- Public API
----------------------------------------------------------

function App:GetVersion()

	return self.Version

end

function App:GetCurrentPage()

	return Navigation:GetCurrent()

end

function App:OpenPage(Page)

	Navigation:Open(Page,self)

end

----------------------------------------------------------
-- Startup Complete
----------------------------------------------------------

print(
	string.format(
		"[SquidNoMo] %s Loaded Successfully.",
		App.Version
	)
)

----------------------------------------------------------
-- Return
----------------------------------------------------------

return App

