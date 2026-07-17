--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Responsive UI Framework
--//========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local App = {}

----------------------------------------------------------
-- Version
----------------------------------------------------------

App.Version = "Beta 5.0"

----------------------------------------------------------
-- Core Modules
----------------------------------------------------------

App.Theme = nil
App.Components = nil
App.Navigation = nil
App.Utilities = nil
App.Notifications = nil

----------------------------------------------------------
-- Main References
----------------------------------------------------------

App.Gui = nil
App.Window = nil
App.Sidebar = nil
App.Header = nil
App.Banner = nil
App.TopNavigation = nil
App.PageContainer = nil

----------------------------------------------------------
-- Pages
----------------------------------------------------------

App.Pages = {}

----------------------------------------------------------
-- Buttons
----------------------------------------------------------

App.NavigationButtons = {}
App.SubNavigationButtons = {}

----------------------------------------------------------
-- Window Settings
----------------------------------------------------------

App.WindowScale = 0.80
App.WindowHeightScale = 0.82

App.MinimumWidth = 950
App.MaximumWidth = 1650

App.MinimumHeight = 560
App.MaximumHeight = 900

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function App:Init(Loader)

	self.Theme = Loader.Theme
	self.Components = Loader.Components
	self.Navigation = Loader.Navigation
	self.Utilities = Loader.Utilities
	self.Notifications = Loader.Notifications

end

----------------------------------------------------------
-- Create ScreenGui
----------------------------------------------------------

function App:CreateGui()

	local Existing =
		LocalPlayer.PlayerGui:FindFirstChild("SquidNoMo")

	if Existing then
		Existing:Destroy()
	end

	local Gui = Instance.new("ScreenGui")

	Gui.Name = "SquidNoMo"

	Gui.IgnoreGuiInset = true

	Gui.ResetOnSpawn = false

	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Gui.Parent = LocalPlayer.PlayerGui

	self.Gui = Gui

	self.Notifications:Init(
		Gui,
		self.Theme
	)

end

----------------------------------------------------------
-- Responsive Size
----------------------------------------------------------

function App:GetWindowSize()

	local Viewport =
		workspace.CurrentCamera.ViewportSize

	local Width =
		math.clamp(

			Viewport.X * self.WindowScale,

			self.MinimumWidth,

			self.MaximumWidth

		)

	local Height =
		math.clamp(

			Viewport.Y * self.WindowHeightScale,

			self.MinimumHeight,

			self.MaximumHeight

		)

	return Width,Height

end

----------------------------------------------------------
-- Create Main Window
----------------------------------------------------------

function App:CreateWindow()

	local Theme = self.Theme

	local Width,Height =
		self:GetWindowSize()

	local Window =
		Instance.new("Frame")

	Window.Name = "Window"

	Window.Size =
		UDim2.fromOffset(
			Width,
			Height
		)

	Window.AnchorPoint =
		Vector2.new(.5,.5)

	Window.Position =
		UDim2.fromScale(.5,.5)

	Window.BackgroundColor3 =
		Theme.Background

	Window.BorderSizePixel = 0

	Window.ClipsDescendants = true

	Window.Parent = self.Gui

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,20)

	Corner.Parent = Window

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Color =
		Theme.BorderDark

	Stroke.Thickness = 1

	Stroke.Parent = Window

	local Scale =
		Instance.new("UIScale")

	Scale.Scale = 1

	Scale.Parent = Window

	self.Window = Window

	self.WindowScaleObject = Scale

	if UserInputService.MouseEnabled then

		self.Utilities:EnableDragging(
			Window,
			Window
		)

	end

end

----------------------------------------------------------
-- Automatic Scaling
----------------------------------------------------------

function App:UpdateScale()

	if not self.Window then
		return
	end

	local Camera =
		workspace.CurrentCamera

	local Viewport =
		Camera.ViewportSize

	local Width,Height =
		self:GetWindowSize()

	self.Window.Size =
		UDim2.fromOffset(
			Width,
			Height
		)

	local Shortest =
		math.min(
			Viewport.X,
			Viewport.Y
		)

	local Scale =
		math.clamp(

			Shortest / 720,

			0.82,

			1.20

		)

	self.WindowScaleObject.Scale =
		Scale

end

----------------------------------------------------------
-- Listen For Resolution Changes
----------------------------------------------------------

function App:StartResponsiveUpdates()

	self:UpdateScale()

	workspace.CurrentCamera
	:GetPropertyChangedSignal("ViewportSize")
	:Connect(function()

		self:UpdateScale()

	end)

end

----------------------------------------------------------
-- Header
----------------------------------------------------------

function App:CreateHeader()

	local Theme = self.Theme

	local Header = Instance.new("Frame")

	Header.Name = "Header"

	Header.Size = UDim2.new(1,0,0,52)

	Header.BackgroundColor3 = Theme.Header

	Header.BorderSizePixel = 0

	Header.Parent = self.Window

	self.Header = Header

	------------------------------------------------------
	-- Title
	------------------------------------------------------

	local Title = Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position = UDim2.fromOffset(18,10)

	Title.Size = UDim2.new(0,260,0,32)

	Title.Font = Theme.FontBlack

	Title.Text = "SquidNoMo"

	Title.TextSize = 24

	Title.TextColor3 = Theme.Text

	Title.TextXAlignment = Enum.TextXAlignment.Left

	Title.Parent = Header

	self.HeaderTitle = Title

	------------------------------------------------------
	-- Version
	------------------------------------------------------

	local Version = Instance.new("TextLabel")

	Version.BackgroundTransparency = 1

	Version.AnchorPoint = Vector2.new(1,0)

	Version.Position = UDim2.new(1,-90,0,14)

	Version.Size = UDim2.new(0,70,0,24)

	Version.Font = Theme.FontBold

	Version.Text = self.Version

	Version.TextSize = 14

	Version.TextColor3 = Theme.Accent

	Version.Parent = Header

	------------------------------------------------------
	-- Close Button
	------------------------------------------------------

	local Close = Instance.new("TextButton")

	Close.Size = UDim2.fromOffset(32,32)

	Close.AnchorPoint = Vector2.new(1,0)

	Close.Position = UDim2.new(1,-10,0,10)

	Close.Text = "✕"

	Close.Font = Theme.FontBlack

	Close.TextSize = 18

	Close.TextColor3 = Theme.Text

	Close.BackgroundColor3 = Theme.Card

	Close.AutoButtonColor = true

	Close.Parent = Header

	local CloseCorner = Instance.new("UICorner")

	CloseCorner.CornerRadius = UDim.new(0,10)

	CloseCorner.Parent = Close

	Close.MouseButton1Click:Connect(function()

		self.Gui.Enabled = false

	end)

	self.CloseButton = Close

end

----------------------------------------------------------
-- Banner
----------------------------------------------------------

function App:CreateBanner()

	local Theme = self.Theme

	local Banner = Instance.new("Frame")

	Banner.Name = "Banner"

	Banner.Position = UDim2.fromOffset(0,52)

	Banner.Size = UDim2.new(1,0,0,170)

	Banner.BackgroundColor3 = Theme.Card

	Banner.BorderSizePixel = 0

	Banner.Parent = self.Window

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,18)

	Corner.Parent = Banner

	------------------------------------------------------
	-- Image
	------------------------------------------------------

	local Image = Instance.new("ImageLabel")

	Image.Name = "BannerImage"

	Image.BackgroundTransparency = 1

	Image.Size = UDim2.fromScale(1,1)

	Image.ScaleType = Enum.ScaleType.Crop

	-- Replace later with your Squid Game X banner asset
	Image.Image = ""

	Image.Parent = Banner

	------------------------------------------------------
	-- Dark Overlay
	------------------------------------------------------

	local Overlay = Instance.new("Frame")

	Overlay.Size = UDim2.fromScale(1,1)

	Overlay.BackgroundColor3 = Color3.new(0,0,0)

	Overlay.BackgroundTransparency = .35

	Overlay.BorderSizePixel = 0

	Overlay.Parent = Banner

	local OverlayCorner = Instance.new("UICorner")

	OverlayCorner.CornerRadius = UDim.new(0,18)

	OverlayCorner.Parent = Overlay

	------------------------------------------------------
	-- Welcome
	------------------------------------------------------

	local Welcome = Instance.new("TextLabel")

	Welcome.BackgroundTransparency = 1

	Welcome.Position = UDim2.fromOffset(24,24)

	Welcome.Size = UDim2.new(.6,0,0,44)

	Welcome.Font = Theme.FontBlack

	Welcome.Text = "Welcome to SquidNoMo"

	Welcome.TextSize = 30

	Welcome.TextColor3 = Theme.Text

	Welcome.TextXAlignment = Enum.TextXAlignment.Left

	Welcome.Parent = Banner

	local Subtitle = Instance.new("TextLabel")

	Subtitle.BackgroundTransparency = 1

	Subtitle.Position = UDim2.fromOffset(24,70)

	Subtitle.Size = UDim2.new(.7,0,0,50)

	Subtitle.Font = Theme.Font

	Subtitle.TextWrapped = true

	Subtitle.Text = "Advanced automation and utilities for Squid Game X."

	Subtitle.TextSize = 16

	Subtitle.TextColor3 = Theme.SubText

	Subtitle.TextXAlignment = Enum.TextXAlignment.Left

	Subtitle.Parent = Banner

	self.Banner = Banner

end

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

function App:CreateSidebar()

	local Theme = self.Theme

	local Sidebar = Instance.new("Frame")

	Sidebar.Name = "Sidebar"

	Sidebar.Position = UDim2.fromOffset(0,222)

	Sidebar.Size = UDim2.new(0,190,1,-222)

	Sidebar.BackgroundColor3 = Theme.Sidebar

	Sidebar.BorderSizePixel = 0

	Sidebar.Parent = self.Window

	local Layout = Instance.new("UIListLayout")

	Layout.Padding = UDim.new(0,8)

	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	Layout.SortOrder = Enum.SortOrder.LayoutOrder

	Layout.Parent = Sidebar

	local Padding = Instance.new("UIPadding")

	Padding.Top = UDim.new(0,18)

	Padding.Left = UDim.new(0,12)

	Padding.Right = UDim.new(0,12)

	Padding.Parent = Sidebar

	self.Sidebar = Sidebar

	------------------------------------------------------
	-- Navigation List
	------------------------------------------------------

	local Pages = {

		{Name="Home",Icon="🏠"},

		{Name="Players",Icon="👤"},

		{Name="Guards",Icon="🛡"},

		{Name="Detective",Icon="🕵"},

		{Name="Farming",Icon="🌱"},

		{Name="VIP",Icon="👑"},

		{Name="Games",Icon="🎮"},

		{Name="Settings",Icon="⚙"}

	}

	for _,Page in ipairs(Pages) do

		local Button = Instance.new("TextButton")

		Button.Name = Page.Name

		Button.Size = UDim2.new(1,0,0,44)

		Button.BackgroundColor3 = Theme.Card

		Button.BorderSizePixel = 0

		Button.AutoButtonColor = true

		Button.Font = Theme.FontBold

		Button.TextSize = 16

		Button.TextColor3 = Theme.Text

		Button.TextXAlignment = Enum.TextXAlignment.Left

		Button.Text = "   "..Page.Icon.."   "..Page.Name

		Button.Parent = Sidebar

		local Corner = Instance.new("UICorner")

		Corner.CornerRadius = UDim.new(0,12)

		Corner.Parent = Button

		Button.MouseButton1Click:Connect(function()

			self:OpenPage(Page.Name)

		end)

		self.NavigationButtons[Page.Name] = Button

	end

end

----------------------------------------------------------
-- Page Area
----------------------------------------------------------

function App:CreatePageContainer()

	local Container = Instance.new("Frame")

	Container.Name = "Pages"

	Container.Position = UDim2.fromOffset(205,222)

	Container.Size = UDim2.new(1,-220,1,-237)

	Container.BackgroundTransparency = 1

	Container.Parent = self.Window

	self.PageContainer = Container

end

----------------------------------------------------------
-- Create Page
----------------------------------------------------------

function App:CreatePage(Name)

	local Page = Instance.new("ScrollingFrame")

	Page.Name = Name

	Page.Size = UDim2.fromScale(1,1)

	Page.CanvasSize = UDim2.new(0,0,0,0)

	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

	Page.ScrollBarThickness = 6

	Page.BackgroundTransparency = 1

	Page.BorderSizePixel = 0

	Page.Visible = false

	Page.Parent = self.PageContainer

	local Padding = Instance.new("UIPadding")

	Padding.Top = UDim.new(0,18)

	Padding.Bottom = UDim.new(0,18)

	Padding.Left = UDim.new(0,18)

	Padding.Right = UDim.new(0,18)

	Padding.Parent = Page

	self.Pages[Name] = Page

	if self.Navigation then

		self.Navigation:Register(
			Name,
			Page
		)

	end

	return Page

end

----------------------------------------------------------
-- Open Page
----------------------------------------------------------

function App:OpenPage(Name)

	if self.Navigation then

		self.Navigation:Open(
			Name,
			self
		)

	end

	------------------------------------------------------
	-- Highlight Active Button
	------------------------------------------------------

	for ButtonName,Button in pairs(self.NavigationButtons) do

		if ButtonName == Name then

			Button.BackgroundColor3 =
				self.Theme.Accent

			Button.TextColor3 =
				Color3.new(1,1,1)

		else

			Button.BackgroundColor3 =
				self.Theme.Card

			Button.TextColor3 =
				self.Theme.Text

		end

	end

end

----------------------------------------------------------
-- Build
----------------------------------------------------------

function App:Build(Loader)

	self:Init(Loader)

	self:CreateGui()

	self:CreateWindow()

	self:StartResponsiveUpdates()

	self:CreateHeader()

	self:CreateBanner()

	self:CreateSidebar()

	self:CreatePageContainer()

	------------------------------------------------------
	-- Home
	------------------------------------------------------

	local Home =
		self:CreatePage("Home")

	Loader.Home:Create(
		Home,
		self
	)

	------------------------------------------------------
	-- Placeholder Pages
	------------------------------------------------------

	self:CreatePage("Players")

	self:CreatePage("Guards")

	self:CreatePage("Detective")

	self:CreatePage("Farming")

	self:CreatePage("VIP")

	self:CreatePage("Games")

	self:CreatePage("Settings")

	------------------------------------------------------
	-- Open Home
	------------------------------------------------------

	self:OpenPage("Home")

	self.Notifications:Success(

		"SquidNoMo",

		"Framework Loaded",

		2

	)

end

----------------------------------------------------------

return App
