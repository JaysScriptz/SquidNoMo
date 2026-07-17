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
