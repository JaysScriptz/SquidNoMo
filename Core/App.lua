--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// App.lua
--//========================================================--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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
-- References
----------------------------------------------------------

App.Gui = nil
App.Window = nil

App.Header = nil
App.Banner = nil
App.Sidebar = nil

App.PageContainer = nil

----------------------------------------------------------
-- Collections
----------------------------------------------------------

App.Pages = {}

App.NavigationButtons = {}

----------------------------------------------------------
-- Window
----------------------------------------------------------

App.Width = 1180
App.Height = 720

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
-- ScreenGui
----------------------------------------------------------

function App:CreateGui()

	local Existing =
		LocalPlayer.PlayerGui:FindFirstChild("SquidNoMo")

	if Existing then
		Existing:Destroy()
	end

	local Gui =
		Instance.new("ScreenGui")

	Gui.Name = "SquidNoMo"

	Gui.IgnoreGuiInset = true

	Gui.ResetOnSpawn = false

	Gui.ZIndexBehavior =
		Enum.ZIndexBehavior.Sibling

	Gui.Parent =
		LocalPlayer.PlayerGui

	self.Gui = Gui

	self.Notifications:Init(

		Gui,
		self.Theme

	)

end

----------------------------------------------------------
-- Window
----------------------------------------------------------

function App:CreateWindow()

	local Theme = self.Theme

	local Window =
		Instance.new("Frame")

	Window.Name = "Window"

	Window.Size =
		UDim2.fromOffset(

			self.Width,
			self.Height

		)

	Window.AnchorPoint =
		Vector2.new(.5,.5)

	Window.Position =
		UDim2.fromScale(.5,.5)

	Window.BackgroundColor3 =
		Theme.Background

	Window.BorderSizePixel = 0

	Window.Parent =
		self.Gui

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

	self.Window = Window

	if UserInputService.MouseEnabled then

		self.Utilities:EnableDragging(

			Window,
			Window

		)

	end

end

----------------------------------------------------------
-- Header
----------------------------------------------------------

function App:CreateHeader()

	local Theme = self.Theme

	local Header =
		Instance.new("Frame")

	Header.Name = "Header"

	Header.Size =
		UDim2.new(1,0,0,52)

	Header.BackgroundColor3 =
		Theme.Header

	Header.BorderSizePixel = 0

	Header.Parent =
		self.Window

	self.Header = Header

	------------------------------------------------------
	-- Title
	------------------------------------------------------

	local Title =
		Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position =
		UDim2.fromOffset(18,9)

	Title.Size =
		UDim2.new(0,260,0,34)

	Title.Font =
		Theme.FontBlack

	Title.Text = "SquidNoMo"

	Title.TextSize = 24

	Title.TextColor3 =
		Theme.Text

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.Parent = Header

	------------------------------------------------------
	-- Version
	------------------------------------------------------

	local Version =
		Instance.new("TextLabel")

	Version.BackgroundTransparency = 1

	Version.AnchorPoint =
		Vector2.new(1,0)

	Version.Position =
		UDim2.new(1,-58,0,14)

	Version.Size =
		UDim2.fromOffset(90,24)

	Version.Font =
		Theme.FontBold

	Version.Text = self.Version

	Version.TextSize = 14

	Version.TextColor3 =
		Theme.Accent

	Version.Parent = Header

	------------------------------------------------------
	-- Close
	------------------------------------------------------

	local Close =
		Instance.new("TextButton")

	Close.Size =
		UDim2.fromOffset(34,34)

	Close.AnchorPoint =
		Vector2.new(1,0)

	Close.Position =
		UDim2.new(1,-10,0,9)

	Close.BackgroundColor3 =
		Theme.Card

	Close.BorderSizePixel = 0

	Close.Text = "✕"

	Close.TextSize = 18

	Close.Font =
		Theme.FontBlack

	Close.TextColor3 =
		Theme.Text

	Close.Parent = Header

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,10)

	Corner.Parent = Close

	Close.MouseButton1Click:Connect(function()

		self.Gui.Enabled = false

	end)

end

----------------------------------------------------------
-- Banner
----------------------------------------------------------

function App:CreateBanner()

	local Theme = self.Theme

	local Banner =
		Instance.new("Frame")

	Banner.Name = "Banner"

	Banner.Position =
		UDim2.fromOffset(0,52)

	Banner.Size =
		UDim2.new(1,0,0,160)

	Banner.BackgroundColor3 =
		Theme.Card

	Banner.BorderSizePixel = 0

	Banner.Parent =
		self.Window

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0,18)

	Corner.Parent = Banner

	local Title =
		Instance.new("TextLabel")

	Title.BackgroundTransparency = 1

	Title.Position =
		UDim2.fromOffset(24,20)

	Title.Size =
		UDim2.new(.8,0,0,40)

	Title.Font =
		Theme.FontBlack

	Title.Text = "Welcome to SquidNoMo"

	Title.TextSize = 28

	Title.TextColor3 =
		Theme.Text

	Title.TextXAlignment =
		Enum.TextXAlignment.Left

	Title.Parent = Banner

	local Subtitle =
		Instance.new("TextLabel")

	Subtitle.BackgroundTransparency = 1

	Subtitle.Position =
		UDim2.fromOffset(24,64)

	Subtitle.Size =
		UDim2.new(.8,0,0,46)

	Subtitle.Font =
		Theme.Font

	Subtitle.TextWrapped = true

	Subtitle.Text =
		"Advanced utilities for Squid Game X."

	Subtitle.TextSize = 16

	Subtitle.TextColor3 =
		Theme.SubText

	Subtitle.TextXAlignment =
		Enum.TextXAlignment.Left

	Subtitle.Parent = Banner

	self.Banner = Banner

end

----------------------------------------------------------
-- Sidebar
----------------------------------------------------------

function App:CreateSidebar()

	local Theme = self.Theme

	local Sidebar =
		Instance.new("Frame")

	Sidebar.Name = "Sidebar"

	Sidebar.Position =
		UDim2.fromOffset(0,212)

	Sidebar.Size =
		UDim2.new(0,190,1,-212)

	Sidebar.BackgroundColor3 =
		Theme.Sidebar

	Sidebar.BorderSizePixel = 0

	Sidebar.Parent =
		self.Window

	local Layout =
		Instance.new("UIListLayout")

	Layout.Padding =
		UDim.new(0,8)

	Layout.HorizontalAlignment =
		Enum.HorizontalAlignment.Center

	Layout.Parent = Sidebar

	local Padding =
		Instance.new("UIPadding")

	Padding.Top =
		UDim.new(0,16)

	Padding.Left =
		UDim.new(0,12)

	Padding.Right =
		UDim.new(0,12)

	Padding.Parent = Sidebar

	self.Sidebar = Sidebar

	local Pages = {

		{"Home","🏠"},
		{"Players","👤"},
		{"Guards","🛡"},
		{"Detective","🕵"},
		{"Farming","🌱"},
		{"VIP","👑"},
		{"Games","🎮"},
		{"Settings","⚙"}

	}

	for _,Info in ipairs(Pages) do

		local Button =
			Instance.new("TextButton")

		Button.Name = Info[1]

		Button.Size =
			UDim2.new(1,0,0,44)

		Button.BackgroundColor3 =
			Theme.Card

		Button.BorderSizePixel = 0

		Button.Font =
			Theme.FontBold

		Button.TextSize = 16

		Button.TextColor3 =
			Theme.Text

		Button.TextXAlignment =
			Enum.TextXAlignment.Left

		Button.Text =
			"   "..Info[2].."   "..Info[1]

		Button.Parent = Sidebar

		local Corner =
			Instance.new("UICorner")

		Corner.CornerRadius =
			UDim.new(0,12)

		Corner.Parent = Button

		Button.MouseButton1Click:Connect(function()

			self:OpenPage(Info[1])

		end)

		self.NavigationButtons[Info[1]] =
			Button

	end

end

----------------------------------------------------------
-- Page Container
----------------------------------------------------------

function App:CreatePageContainer()

	local Container =
		Instance.new("Frame")

	Container.Name = "Pages"

	Container.Position =
		UDim2.fromOffset(205,212)

	Container.Size =
		UDim2.new(1,-220,1,-227)

	Container.BackgroundTransparency = 1

	Container.Parent =
		self.Window

	self.PageContainer = Container

end

----------------------------------------------------------
-- Create Page
----------------------------------------------------------

function App:CreatePage(Name)

	local Page =
		Instance.new("ScrollingFrame")

	Page.Name = Name

	Page.Size =
		UDim2.fromScale(1,1)

	Page.BackgroundTransparency = 1

	Page.BorderSizePixel = 0

	Page.ScrollBarThickness = 6

	Page.CanvasSize =
		UDim2.new(0,0,0,0)

	Page.AutomaticCanvasSize =
		Enum.AutomaticSize.Y

	Page.Visible = false

	Page.Parent =
		self.PageContainer

	local Padding =
		Instance.new("UIPadding")

	Padding.Top =
		UDim.new(0,18)

	Padding.Bottom =
		UDim.new(0,18)

	Padding.Left =
		UDim.new(0,18)

	Padding.Right =
		UDim.new(0,18)

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

	------------------------------------------------------
	-- Initialize
	------------------------------------------------------

	self:Init(Loader)

	------------------------------------------------------
	-- Build UI
	------------------------------------------------------

	self:CreateGui()

	self:CreateWindow()

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
	-- Players
	------------------------------------------------------

	local Players =
		self:CreatePage("Players")

	Loader.Players:Create(

		Players,
		self

	)

	------------------------------------------------------
	-- Remaining Pages
	------------------------------------------------------

	self:CreatePage("Guards")

	self:CreatePage("Detective")

	self:CreatePage("Farming")

	self:CreatePage("VIP")

	self:CreatePage("Games")

	self:CreatePage("Settings")

	------------------------------------------------------
	-- Open Default Page
	------------------------------------------------------

	self:OpenPage("Home")

	------------------------------------------------------
	-- Notification
	------------------------------------------------------

	self.Notifications:Success(

		"SquidNoMo",

		"Framework Loaded",

		2

	)

end

----------------------------------------------------------

return App
