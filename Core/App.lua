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
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")

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
-- Responsive / Floating Overlay
----------------------------------------------------------

-- Logical desktop canvas. The complete desktop suite is kept intact and
-- uniformly scaled into the device-safe placement zone.
App.DesignSize = Vector2.new(1440, 820)

-- The red-box free area measured from the supplied Squid Game X screenshot.
-- These percentages are only used for touch devices in landscape orientation.
App.MobileLandscapeMargins = {
	Left = 0.135,
	Right = 0.185,
	Top = 0.115,
	Bottom = 0.030,
}

-- Portrait still keeps the full desktop suite; it is simply scaled further.
App.MobilePortraitMargins = {
	Left = 0.035,
	Right = 0.035,
	Top = 0.075,
	Bottom = 0.100,
}

App.DesktopViewportFill = 0.78
App.TouchLandscapeFill = 0.96
App.TouchPortraitFill = 0.78

App.MinimumScale = 0.28
App.MaximumScale = 1.15

-- Relative location inside the safe zone. 0.5 / 0.5 is centered.
App.WindowPositionRatio = Vector2.new(0.5, 0.5)
App.WindowWasDragged = false

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
	self.Config = Loader.Config
	self.Features = Loader.Features

	if self.Components and self.Components.Initialize then
		self.Components:Initialize(self.Theme)
	end

end

----------------------------------------------------------
-- UI Parent
----------------------------------------------------------

function App:GetUIParent()
	if type(gethui) == "function" then
		local Success, Result = pcall(gethui)

		if Success and Result then
			return Result
		end
	end

	return CoreGui
end

----------------------------------------------------------
-- Create ScreenGui
----------------------------------------------------------

function App:CreateGui()
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local PreferredParent = self:GetUIParent()

	-- Remove stale copies from both common locations.
	for _, Parent in ipairs({PreferredParent, PlayerGui}) do
		if Parent then
			local Existing = Parent:FindFirstChild("SquidNoMo")

			if Existing then
				Existing:Destroy()
			end
		end
	end

	local Gui = Instance.new("ScreenGui")
	Gui.Name = "SquidNoMo"
	Gui.IgnoreGuiInset = true
	Gui.ResetOnSpawn = false
	Gui.DisplayOrder = 1000000
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

	pcall(function()
		Gui.ScreenInsets = Enum.ScreenInsets.None
		Gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		Gui.ClipToDeviceSafeArea = false
	end)

	if syn and type(syn.protect_gui) == "function" then
		pcall(syn.protect_gui, Gui)
	end

	local ParentSuccess = pcall(function()
		Gui.Parent = PreferredParent
	end)

	if not ParentSuccess then
		Gui.Parent = PlayerGui
	end

	self.Gui = Gui

	if self.Notifications then
		self.Notifications:Init(Gui, self.Theme)
	end
end

----------------------------------------------------------
-- Safe Placement Zone
----------------------------------------------------------

function App:GetSafeRect()
	local Camera = workspace.CurrentCamera
	local Viewport = Camera and Camera.ViewportSize or self.DesignSize

	local Left = 10
	local Right = 10
	local Top = 10
	local Bottom = 10

	local InsetSuccess, TopLeftInset, BottomRightInset = pcall(function()
		return GuiService:GetGuiInset()
	end)

	if InsetSuccess then
		Left = math.max(Left, TopLeftInset.X)
		Top = math.max(Top, TopLeftInset.Y)
		Right = math.max(Right, BottomRightInset.X)
		Bottom = math.max(Bottom, BottomRightInset.Y)
	end

	local IsTouch = UserInputService.TouchEnabled
	local IsLandscape = Viewport.X > Viewport.Y

	if IsTouch and IsLandscape then
		local Margins = self.MobileLandscapeMargins
		Left = math.max(Left, Viewport.X * Margins.Left)
		Right = math.max(Right, Viewport.X * Margins.Right)
		Top = math.max(Top, Viewport.Y * Margins.Top)
		Bottom = math.max(Bottom, Viewport.Y * Margins.Bottom)
	elseif IsTouch then
		local Margins = self.MobilePortraitMargins
		Left = math.max(Left, Viewport.X * Margins.Left)
		Right = math.max(Right, Viewport.X * Margins.Right)
		Top = math.max(Top, Viewport.Y * Margins.Top)
		Bottom = math.max(Bottom, Viewport.Y * Margins.Bottom)
	end

	local Position = Vector2.new(Left, Top)
	local Size = Vector2.new(
		math.max(240, Viewport.X - Left - Right),
		math.max(180, Viewport.Y - Top - Bottom)
	)

	return Position, Size
end

----------------------------------------------------------
-- Window Metrics
----------------------------------------------------------

function App:GetWindowMetrics()
	local SafePosition, SafeSize = self:GetSafeRect()
	local Viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or self.DesignSize
	local IsTouch = UserInputService.TouchEnabled
	local IsLandscape = Viewport.X > Viewport.Y

	local Fill = self.DesktopViewportFill

	if IsTouch and IsLandscape then
		Fill = self.TouchLandscapeFill
	elseif IsTouch then
		Fill = self.TouchPortraitFill
	end

	local TargetWidth = SafeSize.X * Fill
	local TargetHeight = SafeSize.Y * Fill

	local Scale = math.min(
		TargetWidth / self.DesignSize.X,
		TargetHeight / self.DesignSize.Y
	)

	Scale = math.clamp(Scale, self.MinimumScale, self.MaximumScale)

	local DisplaySize = Vector2.new(
		self.DesignSize.X * Scale,
		self.DesignSize.Y * Scale
	)

	-- Never let an enforced minimum scale push the suite beyond the safe zone.
	if DisplaySize.X > SafeSize.X or DisplaySize.Y > SafeSize.Y then
		Scale = math.min(
			SafeSize.X / self.DesignSize.X,
			SafeSize.Y / self.DesignSize.Y
		)

		DisplaySize = Vector2.new(
			self.DesignSize.X * Scale,
			self.DesignSize.Y * Scale
		)
	end

	local Travel = Vector2.new(
		math.max(0, SafeSize.X - DisplaySize.X),
		math.max(0, SafeSize.Y - DisplaySize.Y)
	)

	local Position = SafePosition + Vector2.new(
		Travel.X * self.WindowPositionRatio.X,
		Travel.Y * self.WindowPositionRatio.Y
	)

	return Position, DisplaySize, Scale, SafePosition, SafeSize
end

----------------------------------------------------------
-- Clamp / Move Window
----------------------------------------------------------

function App:SetWindowScreenPosition(X, Y, RememberPosition)
	if not self.Window then
		return
	end

	local _, DisplaySize, _, SafePosition, SafeSize = self:GetWindowMetrics()
	local MaxX = SafePosition.X + math.max(0, SafeSize.X - DisplaySize.X)
	local MaxY = SafePosition.Y + math.max(0, SafeSize.Y - DisplaySize.Y)

	local ClampedX = math.clamp(X, SafePosition.X, MaxX)
	local ClampedY = math.clamp(Y, SafePosition.Y, MaxY)

	self.Window.Position = UDim2.fromOffset(ClampedX, ClampedY)

	if RememberPosition then
		local TravelX = math.max(0, MaxX - SafePosition.X)
		local TravelY = math.max(0, MaxY - SafePosition.Y)

		self.WindowPositionRatio = Vector2.new(
			TravelX > 0 and ((ClampedX - SafePosition.X) / TravelX) or 0.5,
			TravelY > 0 and ((ClampedY - SafePosition.Y) / TravelY) or 0.5
		)

		self.WindowWasDragged = true
	end
end

----------------------------------------------------------
-- Resize / Reposition Window
----------------------------------------------------------

function App:UpdateWindow()
	if not self.Window then
		return
	end

	local Position, _, Scale = self:GetWindowMetrics()

	self.Window.Size = UDim2.fromOffset(
		self.DesignSize.X,
		self.DesignSize.Y
	)

	if self.WindowScale then
		self.WindowScale.Scale = Scale
	end

	self.Window.Position = UDim2.fromOffset(Position.X, Position.Y)

	task.defer(function()
		self:UpdateLayout()
	end)
end

----------------------------------------------------------
-- Create Window
----------------------------------------------------------

function App:CreateWindow()
	local Theme = self.Theme
	local Position, _, Scale = self:GetWindowMetrics()

	local Window = Instance.new("Frame")
	Window.Name = "Window"
	Window.AnchorPoint = Vector2.zero
	Window.Position = UDim2.fromOffset(Position.X, Position.Y)
	Window.Size = UDim2.fromOffset(self.DesignSize.X, self.DesignSize.Y)
	Window.BackgroundColor3 = Theme.Background
	Window.BorderSizePixel = 0
	Window.ClipsDescendants = true
	Window.Active = true
	Window.ZIndex = 1
	Window.Parent = self.Gui

	local WindowScale = Instance.new("UIScale")
	WindowScale.Name = "ResponsiveScale"
	WindowScale.Scale = Scale
	WindowScale.Parent = Window

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,18)
	Corner.Parent = Window

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.BorderDark
	Stroke.Thickness = 1
	Stroke.Parent = Window

	self.Window = Window
	self.WindowScale = WindowScale
end

----------------------------------------------------------
-- Responsive Layout
----------------------------------------------------------

function App:UpdateLayout()
	if not self.Window then
		return
	end

	-- Keep the complete desktop navigation on touch devices.
	local SidebarWidth = 220

	if self.Sidebar then
		self.Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -256)
	end

	if self.PageContainer then
		local Left = 18 + SidebarWidth + 18
		self.PageContainer.Position = UDim2.fromOffset(Left, 238)
		self.PageContainer.Size = UDim2.new(1, -(Left + 18), 1, -256)
	end

	for _, Button in pairs(self.NavigationButtons) do
		if Button.SetCompact then
			Button:SetCompact(false)
		end
	end
end

----------------------------------------------------------
-- Mouse + Touch Dragging
----------------------------------------------------------

function App:EnableWindowDragging(DragBar)
	if not DragBar or not self.Window then
		return
	end

	DragBar.Active = true

	local Dragging = false
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function IsDragStart(Input)
		return Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
	end

	DragBar.InputBegan:Connect(function(Input)
		if not IsDragStart(Input) then
			return
		end

		Dragging = true
		DragInput = Input
		DragStart = Input.Position
		StartPosition = Vector2.new(
			self.Window.Position.X.Offset,
			self.Window.Position.Y.Offset
		)

		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
				DragInput = nil
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if not Dragging or not DragStart or not StartPosition then
			return
		end

		local IsTouchMove = DragInput
			and DragInput.UserInputType == Enum.UserInputType.Touch
			and Input == DragInput

		local IsMouseMove = DragInput
			and DragInput.UserInputType == Enum.UserInputType.MouseButton1
			and Input.UserInputType == Enum.UserInputType.MouseMovement

		if not IsTouchMove and not IsMouseMove then
			return
		end

		local Delta = Input.Position - DragStart

		self:SetWindowScreenPosition(
			StartPosition.X + Delta.X,
			StartPosition.Y + Delta.Y,
			true
		)
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
			DragInput = nil
		end
	end)
end

----------------------------------------------------------
-- Responsive Updates
----------------------------------------------------------

function App:StartResponsive()
	task.spawn(function()
		local Camera = workspace.CurrentCamera

		while not Camera do
			task.wait()
			Camera = workspace.CurrentCamera
		end

		self:UpdateWindow()

		if self.ViewportConnection then
			self.ViewportConnection:Disconnect()
		end

		self.ViewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:UpdateWindow()
		end)
	end)
end

----------------------------------------------------------
-- Header
----------------------------------------------------------

function App:CreateHeader()
	local Theme = self.Theme

	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1,0,0,56)
	Header.BackgroundColor3 = Theme.Header
	Header.BorderSizePixel = 0
	Header.Active = true
	Header.ZIndex = 10
	Header.Parent = self.Window

	self.Header = Header

	local Stroke = Instance.new("UIStroke")
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Color = Theme.BorderDark
	Stroke.Thickness = 1
	Stroke.Parent = Header

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(18,8)
	Title.Size = UDim2.new(0,240,0,26)
	Title.Font = Theme.FontBlack
	Title.Text = "SquidNoMo"
	Title.TextSize = 24
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 11
	Title.Parent = Header

	self.HeaderTitle = Title

	local Version = Instance.new("TextLabel")
	Version.BackgroundTransparency = 1
	Version.Position = UDim2.fromOffset(20,30)
	Version.Size = UDim2.new(0,150,0,18)
	Version.Font = Theme.Font
	Version.Text = self.Version
	Version.TextSize = 13
	Version.TextColor3 = Theme.SubText
	Version.TextXAlignment = Enum.TextXAlignment.Left
	Version.ZIndex = 11
	Version.Parent = Header

	-- Large transparent touch target with the original compact visual button.
	local CloseHitbox = Instance.new("TextButton")
	CloseHitbox.Name = "CloseHitbox"
	CloseHitbox.Size = UDim2.fromOffset(72,56)
	CloseHitbox.AnchorPoint = Vector2.new(1,0)
	CloseHitbox.Position = UDim2.new(1,0,0,0)
	CloseHitbox.BackgroundTransparency = 1
	CloseHitbox.Text = ""
	CloseHitbox.AutoButtonColor = false
	CloseHitbox.ZIndex = 20
	CloseHitbox.Parent = Header

	local Close = Instance.new("TextLabel")
	Close.Name = "Visual"
	Close.Size = UDim2.fromOffset(38,38)
	Close.AnchorPoint = Vector2.new(0.5,0.5)
	Close.Position = UDim2.fromScale(0.5,0.5)
	Close.BackgroundColor3 = Theme.Card
	Close.Text = "✕"
	Close.Font = Theme.FontBlack
	Close.TextSize = 18
	Close.TextColor3 = Theme.Text
	Close.ZIndex = 21
	Close.Parent = CloseHitbox

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0,10)
	Corner.Parent = Close

	CloseHitbox.MouseButton1Click:Connect(function()
		self.Gui.Enabled = false
	end)

	self.CloseButton = CloseHitbox
	self:EnableWindowDragging(Header)
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
		Instance.new("ScrollingFrame")

	Sidebar.Name =
		"Sidebar"

	Sidebar.Position =
		UDim2.fromOffset(18,238)

	Sidebar.Size =
		UDim2.new(0,220,1,-256)

	Sidebar.BackgroundColor3 =
		Theme.Card

	Sidebar.BorderSizePixel = 0
	Sidebar.CanvasSize = UDim2.new(0,0,0,0)
	Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Sidebar.ScrollBarThickness = 3
	Sidebar.ScrollBarImageColor3 = Theme.Accent

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
		
