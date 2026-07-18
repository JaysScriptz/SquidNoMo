--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Core/App.lua
--//========================================================--

----------------------------------------------------------
-- Services
----------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------
-- App
----------------------------------------------------------

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
-- References
----------------------------------------------------------

App.Gui = nil
App.Window = nil
App.Header = nil
App.Banner = nil
App.Sidebar = nil
App.PageContainer = nil

----------------------------------------------------------
-- Storage
----------------------------------------------------------

App.Pages = {}

App.NavigationButtons = {}

App.SubNavigationButtons = {}

----------------------------------------------------------
-- Responsive
----------------------------------------------------------

App.Padding = 24

App.MinWidth = 340

App.MaxWidth = 1280

App.MinHeight = 480

App.MaxHeight = 820

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function App:Init(Loader)

	self.Loader = Loader

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
		LocalPlayer.PlayerGui:FindFirstChild(
			"SquidNoMo"
		)

	if Existing then

		Existing:Destroy()

	end

	local Gui =
		Instance.new("ScreenGui")

	Gui.Name =
		"SquidNoMo"

	Gui.IgnoreGuiInset = true

	Gui.ResetOnSpawn = false

	Gui.ZIndexBehavior =
		Enum.ZIndexBehavior.Sibling

	Gui.Parent =
		LocalPlayer.PlayerGui

	self.Gui = Gui

	if self.Notifications then

		self.Notifications:Init(

			Gui,

			self.Theme

		)

	end

end

----------------------------------------------------------
-- Viewport Size
----------------------------------------------------------

function App:GetWindowSize()

	local Camera =
		workspace.CurrentCamera

	if not Camera then

		return 900,600

	end

	local Viewport =
		Camera.ViewportSize

	local Width =
		math.clamp(

			Viewport.X - (self.Padding * 2),

			self.MinWidth,

			self.MaxWidth

		)

	local Height =
		math.clamp(

			Viewport.Y - (self.Padding * 3),

			self.MinHeight,

			self.MaxHeight

		)

	return Width,Height

end

----------------------------------------------------------
-- Resize Window
----------------------------------------------------------

function App:UpdateWindow()

	if not self.Window then
		return
	end

	local Width,Height =
		self:GetWindowSize()

	self.Window.Size =
		UDim2.fromOffset(

			Width,

			Height

		)

end

----------------------------------------------------------
-- Create Window
----------------------------------------------------------

function App:CreateWindow()

	local Theme =
		self.Theme

	local Width,Height =
		self:GetWindowSize()

	local Window =
		Instance.new("Frame")

	Window.Name =
		"Window"

	Window.AnchorPoint =
		Vector2.new(.5,.5)

	Window.Position =
		UDim2.fromScale(.5,.5)

	Window.Size =
		UDim2.fromOffset(

			Width,

			Height

		)

	Window.BackgroundColor3 =
		Theme.Background

	Window.BorderSizePixel = 0

	Window.ClipsDescendants = true

	Window.Parent =
		self.Gui

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,18)

	Corner.Parent =
		Window

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Color =
		Theme.BorderDark

	Stroke.Thickness = 1

	Stroke.Parent =
		Window

	self.Window =
		Window

	if UserInputService.MouseEnabled
	and self.Utilities
	and self.Utilities.EnableDragging then

		self.Utilities:EnableDragging(

			Window,

			Window

		)

	end

end

----------------------------------------------------------
-- Responsive Updates
----------------------------------------------------------

function App:StartResponsive()

	task.spawn(function()

		local Camera =
			workspace.CurrentCamera

		while not Camera do

			task.wait()

			Camera =
				workspace.CurrentCamera

		end

		self:UpdateWindow()

		Camera:GetPropertyChangedSignal(
			"ViewportSize"
		):Connect(function()

			self:UpdateWindow()

		end)

	end)

end

----------------------------------------------------------
-- Header
----------------------------------------------------------

function App:CreateHeader()

	local Theme =
		self.Theme

	local Header =
		Instance.new("Frame")

	Header.Name =
		"Header"

	Header.Size =
		UDim2.new(1,0,0,56)

	Header.BackgroundColor3 =
		Theme.Header

	Header.BorderSizePixel = 0

	Header.Parent =
		self.Window

	self.Header =
		Header

	------------------------------------------------------
	-- Bottom Stroke
	------------------------------------------------------

	local Stroke =
		Instance.new("UIStroke")

	Stroke.ApplyStrokeMode =
		Enum.ApplyStrokeMode.Border

	Stroke.Color =
		Theme.BorderDark

	Stroke.Thickness = 1

	Stroke.Parent =
		Header

------------------------------------------------------
-- Title
------------------------------------------------------

	local Title =
		Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position =
		UDim2.fromOffset(18,8)

	Title.Size =
		UDim2.new(0,240,0,26)

	Title.Font =
		Theme.FontBlack

	Title.Text =
		"SquidNoMo"

	Title.TextSize = 24

	Title.TextColor3 =
		Theme.Text

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.Parent =
		Header

	self.HeaderTitle = Title

------------------------------------------------------
-- Version
------------------------------------------------------

	local Version =
		Instance.new("TextLabel")

	Version.BackgroundTransparency = 1

	Version.Position =
		UDim2.fromOffset(20,30)

	Version.Size =
		UDim2.new(0,150,0,18)

	Version.Font =
		Theme.Font

	Version.Text =
		self.Version

	Version.TextSize = 13

	Version.TextColor3 =
		Theme.SubText

	Version.TextXAlignment =
		Enum.TextXAlignment.Left

	Version.Parent =
		Header

------------------------------------------------------
-- Close Button
------------------------------------------------------

	local Close =
		Instance.new("TextButton")

	Close.Size =
		UDim2.fromOffset(34,34)

	Close.AnchorPoint =
		Vector2.new(1,0)

	Close.Position =
		UDim2.new(1,-12,0,11)

	Close.BackgroundColor3 =
		Theme.Card

	Close.Text = "✕"

	Close.Font =
		Theme.FontBlack

	Close.TextSize = 18

	Close.TextColor3 =
		Theme.Text

	Close.AutoButtonColor = true

	Close.Parent =
		Header

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,10)

	Corner.Parent =
		Close

	Close.MouseButton1Click:Connect(function()

		self.Gui.Enabled = false

	end)

	self.CloseButton = Close

end

----------------------------------------------------------
-- Banner
----------------------------------------------------------

function App:CreateBanner()

	local Theme =
		self.Theme

	local Banner =
		Instance.new("Frame")

	Banner.Name =
		"Banner"

	Banner.Position =
		UDim2.fromOffset(18,72)

	Banner.Size =
		UDim2.new(1,-36,0,150)

	Banner.BackgroundColor3 =
		Theme.Card

	Banner.BorderSizePixel = 0

	Banner.Parent =
		self.Window

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,18)

	Corner.Parent =
		Banner

------------------------------------------------------
-- Welcome
------------------------------------------------------

	local Welcome =
		Instance.new("TextLabel")

	Welcome.BackgroundTransparency = 1

	Welcome.Position =
		UDim2.fromOffset(20,20)

	Welcome.Size =
		UDim2.new(1,-40,0,34)

	Welcome.Font =
		Theme.FontBlack

	Welcome.Text =
		"Welcome to SquidNoMo"

	Welcome.TextSize = 28

	Welcome.TextColor3 =
		Theme.Text

	Welcome.TextXAlignment =
		Enum.TextXAlignment.Left

	Welcome.Parent =
		Banner

------------------------------------------------------
-- Subtitle
------------------------------------------------------

	local Subtitle =
		Instance.new("TextLabel")

	Subtitle.BackgroundTransparency = 1

	Subtitle.Position =
		UDim2.fromOffset(20,58)

	Subtitle.Size =
		UDim2.new(1,-40,0,48)

	Subtitle.Font =
		Theme.Font

	Subtitle.TextWrapped = true

	Subtitle.Text =
		"Advanced automation, ESP and utilities for Squid Game X."

	Subtitle.TextSize = 16

	Subtitle.TextColor3 =
		Theme.SubText

	Subtitle.TextXAlignment =
		Enum.TextXAlignment.Left

	Subtitle.TextYAlignment =
		Enum.TextYAlignment.Top

	Subtitle.Parent =
		Banner

	self.Banner =
		Banner

end

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

function App:CreateSidebar()

	local Theme =
		self.Theme

	local Sidebar =
		Instance.new("Frame")

	Sidebar.Name =
		"Sidebar"

	Sidebar.Position =
		UDim2.fromOffset(18,238)

	Sidebar.Size =
		UDim2.fromOffset(220,
			self.Window.AbsoluteSize.Y - 256)

	Sidebar.BackgroundColor3 =
		Theme.Card

	Sidebar.BorderSizePixel = 0

	Sidebar.Parent =
		self.Window

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,18)

	Corner.Parent =
		Sidebar

	local Layout =
		Instance.new("UIListLayout")

	Layout.Padding =
		UDim.new(0,8)

	Layout.HorizontalAlignment =
		Enum.HorizontalAlignment.Center

	Layout.SortOrder =
		Enum.SortOrder.LayoutOrder

	Layout.Parent =
		Sidebar

	local Padding =
		Instance.new("UIPadding")

	Padding.PaddingTop =
		UDim.new(0,16)

	Padding.PaddingBottom =
		UDim.new(0,16)

	Padding.PaddingLeft =
		UDim.new(0,12)

	Padding.PaddingRight =
		UDim.new(0,12)

	Padding.Parent =
		Sidebar

	self.Sidebar =
		Sidebar

end

----------------------------------------------------------
-- Sidebar Button
----------------------------------------------------------

function App:AddSidebarButton(

	Name,
	Icon,
	PageName

)

	local Button =
		self.Components:SidebarButton(

			self.Sidebar,

			Name,

			Icon

		)

	Button.MouseButton1Click:Connect(function()

		self:OpenPage(
			PageName
		)

	end)

	self.NavigationButtons[
		PageName
	] = Button

	return Button

end

----------------------------------------------------------
-- Build Sidebar
----------------------------------------------------------

function App:BuildSidebar()

	self:AddSidebarButton(

		"Home",

		"🏠",

		"Home"

	)

	self:AddSidebarButton(

		"Players",

		"👤",

		"Players"

	)

	self:AddSidebarButton(

		"Guards",

		"🛡️",

		"Guards"

	)

	self:AddSidebarButton(

		"Detective",

		"🕵️",

		"Detective"

	)

	self:AddSidebarButton(

		"Farming",

		"🌾",

		"Farming"

	)

	self:AddSidebarButton(

		"Games",

		"🎮",

		"Games"

	)

	self:AddSidebarButton(

		"VIP",

		"⭐",

		"VIP"

	)

	self:AddSidebarButton(

		"Settings",

		"⚙️",

		"Settings"

	)

end
----------------------------------------------------------
-- Page Container
----------------------------------------------------------

function App:CreatePageContainer()

	local Theme =
		self.Theme

	local Container =
		Instance.new("Frame")

	Container.Name =
		"PageContainer"

	Container.Position =
		UDim2.new(
			0,
			256,
			0,
			238
		)

	Container.Size =
		UDim2.new(
			1,
			-274,
			1,
			-256
		)

	Container.BackgroundTransparency = 1

	Container.ClipsDescendants = true

	Container.Parent =
		self.Window

	self.PageContainer =
		Container

end

----------------------------------------------------------
-- Create Page
----------------------------------------------------------

function App:CreatePage(Name)

	local Page =
		Instance.new("ScrollingFrame")

	Page.Name =
		Name

	Page.Size =
		UDim2.fromScale(1,1)

	Page.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			0
		)

	Page.ScrollBarThickness = 4

	Page.BackgroundTransparency = 1

	Page.Visible = false

	Page.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	Page.Parent =
		self.PageContainer

	local Layout =
		Instance.new("UIListLayout")

	Layout.Padding =
		UDim.new(0,12)

	Layout.HorizontalAlignment =
		Enum.HorizontalAlignment.Center

	Layout.SortOrder =
		Enum.SortOrder.LayoutOrder

	Layout.Parent =
		Page

	local Padding =
		Instance.new("UIPadding")

	Padding.PaddingTop =
		UDim.new(0,4)

	Padding.PaddingBottom =
		UDim.new(0,12)

	Padding.PaddingLeft =
		UDim.new(0,4)

	Padding.PaddingRight =
		UDim.new(0,4)

	Padding.Parent =
		Page

	self.Pages[Name] =
		Page

	return Page

end

----------------------------------------------------------
-- Open Page
----------------------------------------------------------

function App:OpenPage(Name)

	for PageName, Page in pairs(self.Pages) do

		Page.Visible = (PageName == Name)

	end

	for PageName, Button in pairs(self.NavigationButtons) do

		if Button.SetSelected then

			Button:SetSelected(PageName == Name)

		end

	end

	self.CurrentPage = Name

	print("[SquidNoMo] Opened Page:", Name)

end

----------------------------------------------------------
-- Build Pages
----------------------------------------------------------

function App:BuildPages()

	local Home = self:CreatePage("Home")

	if self.Loader.Home and self.Loader.Home.Create then

		local Success, Error = pcall(function()

			self.Loader.Home:Create(
				Home,
				self
			)

		end)

		if not Success then

			warn("[Home]", Error)

		end

	end

	local Players = self:CreatePage("Players")

	if self.Loader.Players and self.Loader.Players.Create then

		local Success, Error = pcall(function()

			self.Loader.Players:Create(
				Players,
				self
			)

		end)

		if not Success then

			warn("[Players]", Error)

		end

	end

	self:CreatePage("Guards")
	self:CreatePage("Detective")
	self:CreatePage("Farming")
	self:CreatePage("Games")
	self:CreatePage("VIP")
	self:CreatePage("Settings")

end

------------------------------------------------------
-- Home
------------------------------------------------------

	local Home =
		self:CreatePage("Home")

	if self.Loader.Home
	and self.Loader.Home.Create then

		self.Loader.Home:Create(
			Home,
			self
		)

	end

------------------------------------------------------
-- Players
------------------------------------------------------

	local Players =
		self:CreatePage("Players")

	if self.Loader.Players
	and self.Loader.Players.Create then

		self.Loader.Players:Create(
			Players,
			self
		)

	end

------------------------------------------------------
-- Placeholder Pages
------------------------------------------------------

	self:CreatePage("Guards")

	self:CreatePage("Detective")

	self:CreatePage("Farming")

	self:CreatePage("Games")

	self:CreatePage("VIP")

	self:CreatePage("Settings")

end

----------------------------------------------------------
-- Finish Build
----------------------------------------------------------

function App:FinishBuild()

	self:BuildSidebar()

	self:BuildPages()

	self:OpenPage("Home")

	self:StartResponsive()

end

----------------------------------------------------------
-- Build
----------------------------------------------------------

function App:Build(Loader)

	------------------------------------------------------
	-- Init
	------------------------------------------------------

	self:Init(Loader)

	------------------------------------------------------
	-- GUI
	------------------------------------------------------

	self:CreateGui()

	self:CreateWindow()

	self:CreateHeader()

	self:CreateBanner()

	self:CreateSidebar()

	self:CreatePageContainer()

	------------------------------------------------------
	-- Build Content
	------------------------------------------------------

	self:FinishBuild()

	------------------------------------------------------
	-- Notify
	------------------------------------------------------

	if self.Notifications then

		self.Notifications:Success(

			"SquidNoMo",

			"Loaded Successfully"

		)

	end

end

----------------------------------------------------------
-- Destroy
----------------------------------------------------------

function App:Destroy()

	if self.Gui then

		self.Gui:Destroy()

		self.Gui = nil

	end

	self.Pages = {}

	self.NavigationButtons = {}

	self.SubNavigationButtons = {}

end

----------------------------------------------------------
-- Get Page
----------------------------------------------------------

function App:GetPage(Name)

	return self.Pages[Name]

end

----------------------------------------------------------
-- Get Window
----------------------------------------------------------

function App:GetWindow()

	return self.Window

end

----------------------------------------------------------
-- Get Theme
----------------------------------------------------------

function App:GetTheme()

	return self.Theme

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return App

