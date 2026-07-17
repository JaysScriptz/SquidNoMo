--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// App.lua
--//========================================================--

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local App = {}

----------------------------------------------------------
-- Modules
----------------------------------------------------------

App.Theme = nil
App.Components = nil
App.Navigation = nil
App.Utilities = nil
App.Notifications = nil

----------------------------------------------------------
-- Window
----------------------------------------------------------

App.Gui = nil
App.Window = nil
App.Sidebar = nil
App.Header = nil
App.PageContainer = nil

----------------------------------------------------------
-- Pages
----------------------------------------------------------

App.Pages = {}

----------------------------------------------------------
-- Navigation Buttons
----------------------------------------------------------

App.NavigationButtons = {}

----------------------------------------------------------
-- Version
----------------------------------------------------------

App.Version = "Beta 5.0"

----------------------------------------------------------
-- Initialize Modules
----------------------------------------------------------

function App:Init(Loader)

	self.Theme = Loader.Theme
	self.Components = Loader.Components
	self.Navigation = Loader.Navigation
	self.Utilities = Loader.Utilities
	self.Notifications = Loader.Notifications

end

----------------------------------------------------------
-- ScreenGui
----------------------------------------------------------

function App:CreateGui()

	if LocalPlayer.PlayerGui:FindFirstChild("SquidNoMo") then

		LocalPlayer.PlayerGui.SquidNoMo:Destroy()

	end

	local Gui = Instance.new("ScreenGui")

	Gui.Name = "SquidNoMo"

	Gui.IgnoreGuiInset = true

	Gui.ResetOnSpawn = false

	Gui.Parent = LocalPlayer.PlayerGui

	self.Gui = Gui

	self.Notifications:Init(
		Gui,
		self.Theme
	)

end

----------------------------------------------------------
-- Main Window
----------------------------------------------------------

function App:CreateWindow()

	local Theme = self.Theme

	local Window =
		Instance.new("Frame")

	Window.Name = "Window"

	Window.Size =
		UDim2.fromOffset(
			Theme.WindowWidth,
			Theme.WindowHeight
		)

	Window.AnchorPoint =
		Vector2.new(.5,.5)

	Window.Position =
		UDim2.fromScale(.5,.5)

	Window.BackgroundColor3 =
		Theme.Background

	Window.BorderSizePixel = 0

	Window.Parent = self.Gui

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,18)

	Corner.Parent = Window

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Color =
		Theme.BorderDark

	Stroke.Thickness = 1

	Stroke.Parent = Window

	self.Utilities:EnableDragging(
		Window,
		Window
	)

	self.Window = Window

end

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

function App:CreateSidebar()

	local Theme = self.Theme

	local Sidebar =
		Instance.new("Frame")

	Sidebar.Name = "Sidebar"

	Sidebar.Size =
		UDim2.new(
			0,
			Theme.SidebarWidth,
			1,
			0
		)

	Sidebar.BackgroundColor3 =
		Theme.Sidebar

	Sidebar.BorderSizePixel = 0

	Sidebar.Parent =
		self.Window

	self.Sidebar = Sidebar

end

----------------------------------------------------------
-- Header
----------------------------------------------------------

function App:CreateHeader()

	local Theme = self.Theme

	local Header =
		Instance.new("Frame")

	Header.Name = "Header"

	Header.Position =
		UDim2.new(
			0,
			Theme.SidebarWidth,
			0,
			0
		)

	Header.Size =
		UDim2.new(
			1,
			-Theme.SidebarWidth,
			0,
			Theme.HeaderHeight
		)

	Header.BackgroundColor3 =
		Theme.Header

	Header.BorderSizePixel = 0

	Header.Parent =
		self.Window

	local Title =
		Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position =
		UDim2.fromOffset(
			24,
			18
		)

	Title.Size =
		UDim2.new(
			1,
			-48,
			0,
			30
		)

	Title.Font =
		Theme.FontBlack

	Title.Text =
		"Dashboard"

	Title.TextSize = 26

	Title.TextColor3 =
		Theme.Text

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.Parent = Header

	self.Header = Header

	self.HeaderTitle = Title

end
----------------------------------------------------------
-- Page Container
----------------------------------------------------------

function App:CreatePageContainer()

	local Theme = self.Theme

	local Container = Instance.new("Frame")

	Container.Name = "Pages"

	Container.Position = UDim2.new(
		0,
		Theme.SidebarWidth,
		0,
		Theme.HeaderHeight
	)

	Container.Size = UDim2.new(
		1,
		-Theme.SidebarWidth,
		1,
		-Theme.HeaderHeight
	)

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

	Page.CanvasSize = UDim2.new(0,0,0,1700)

	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

	Page.ScrollBarThickness = 6

	Page.BackgroundTransparency = 1

	Page.BorderSizePixel = 0

	Page.Visible = false

	Page.Parent = self.PageContainer

	self.Navigation:Register(
		Name,
		Page
	)

	self.Pages[Name] = Page

	return Page

end

----------------------------------------------------------
-- Open Page
----------------------------------------------------------

function App:OpenPage(Name)

	self.Navigation:Open(
		Name,
		self
	)

end

----------------------------------------------------------
-- Build
----------------------------------------------------------

function App:Build(Loader)

	self:Init(Loader)

	self:CreateGui()

	self:CreateWindow()

	self:CreateSidebar()

	self:CreateHeader()

	self:CreatePageContainer()

	local HomePage =
		self:CreatePage("Home")

	Loader.Home:Create(
		HomePage,
		self
	)

	self:OpenPage("Home")

end

return App


