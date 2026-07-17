--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Navigation.lua
--//========================================================--

local Navigation = {}

Navigation.Pages = {}

Navigation.CurrentPage = nil

----------------------------------------------------------
-- Register Page
----------------------------------------------------------

function Navigation:Register(PageName, PageFrame)

	self.Pages[PageName] = PageFrame

	PageFrame.Visible = false

end

----------------------------------------------------------
-- Open Page
----------------------------------------------------------

function Navigation:Open(PageName, App)

	if self.CurrentPage == PageName then
		return
	end

	------------------------------------------------------
	-- Hide All Pages
	------------------------------------------------------

	for _, Page in pairs(self.Pages) do
		Page.Visible = false
	end

	------------------------------------------------------
	-- Reset Navigation Buttons
	------------------------------------------------------

	if App and App.NavigationButtons then

		for _, Data in pairs(App.NavigationButtons) do

			Data.Button.BackgroundColor3 = App.Theme.Card

			Data.Label.TextColor3 = App.Theme.SubText

			Data.Indicator.Visible = false

		end

	end

	------------------------------------------------------
	-- Show Selected Page
	------------------------------------------------------

	local SelectedPage = self.Pages[PageName]

	if SelectedPage then

		SelectedPage.Visible = true

	end

	------------------------------------------------------
	-- Highlight Button
	------------------------------------------------------

	if App
		and App.NavigationButtons
		and App.NavigationButtons[PageName] then

		local Button = App.NavigationButtons[PageName]

		Button.Button.BackgroundColor3 = App.Theme.CardHover

		Button.Label.TextColor3 = App.Theme.Text

		Button.Indicator.Visible = true

	end

	------------------------------------------------------
	-- Update Header
	------------------------------------------------------

	if App and App.HeaderTitle then

		local Titles = {

			Home = "Dashboard",

			Players = "Players",

			Guards = "Guards",

			Detective = "Detective",

			Farming = "Farming",

			VIP = "VIP",

			Games = "Games",

			Settings = "Settings",

			Support = "Support Development"

		}

		App.HeaderTitle.Text = Titles[PageName] or PageName

	end

	self.CurrentPage = PageName

end

----------------------------------------------------------
-- Remove Page
----------------------------------------------------------

function Navigation:Remove(PageName)

	if self.Pages[PageName] then

		self.Pages[PageName]:Destroy()

		self.Pages[PageName] = nil

	end

end

----------------------------------------------------------
-- Get Current
----------------------------------------------------------

function Navigation:GetCurrent()

	return self.CurrentPage

end

----------------------------------------------------------
-- Exists
----------------------------------------------------------

function Navigation:Exists(PageName)

	return self.Pages[PageName] ~= nil

end

----------------------------------------------------------
-- Get Page
----------------------------------------------------------

function Navigation:Get(PageName)

	return self.Pages[PageName]

end

----------------------------------------------------------
-- Clear All
----------------------------------------------------------

function Navigation:Clear()

	for _, Page in pairs(self.Pages) do

		Page:Destroy()

	end

	table.clear(self.Pages)

	self.CurrentPage = nil

end

return Navigation
