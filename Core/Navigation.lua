--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Navigation.lua
--//========================================================--

local TweenService = game:GetService("TweenService")

local Navigation = {}

Navigation.Pages = {}

Navigation.CurrentPage = nil

Navigation.TweenInfo =
	TweenInfo.new(

		0.20,

		Enum.EasingStyle.Quad,

		Enum.EasingDirection.Out

	)

----------------------------------------------------------
-- Register Page
----------------------------------------------------------

function Navigation:Register(Name, Page)

	self.Pages[Name] = Page

	Page.Visible = false

	Page.BackgroundTransparency = 1

end

----------------------------------------------------------
-- Hide All Pages
----------------------------------------------------------

function Navigation:HideAll()

	for _,Page in pairs(self.Pages) do

		Page.Visible = false

	end

end

----------------------------------------------------------
-- Fade In
----------------------------------------------------------

function Navigation:FadeIn(Page)

	Page.BackgroundTransparency = 1

	local Tween = TweenService:Create(

		Page,

		self.TweenInfo,

		{

			BackgroundTransparency = 0

		}

	)

	Tween:Play()

end

----------------------------------------------------------
-- Open Page
----------------------------------------------------------

function Navigation:Open(Name, App)

	local Page = self.Pages[Name]

	if not Page then
		warn("[Navigation] Missing page:", Name)
		return
	end

	------------------------------------------------------
	-- Hide Previous Page
	------------------------------------------------------

	if self.CurrentPage then
		self.CurrentPage.Visible = false
	end

	------------------------------------------------------
	-- Show New Page
	------------------------------------------------------

	Page.Visible = true

	self:FadeIn(Page)

	self.CurrentPage = Page

	------------------------------------------------------
	-- Sidebar Highlight
	------------------------------------------------------

	if App and App.NavigationButtons then

		for ButtonName,Button in pairs(App.NavigationButtons) do

			if ButtonName == Name then

				Button.BackgroundColor3 =
					App.Theme.Accent

				Button.TextColor3 =
					Color3.new(1,1,1)

			else

				Button.BackgroundColor3 =
					App.Theme.Card

				Button.TextColor3 =
					App.Theme.Text

			end

		end

	end

end

----------------------------------------------------------
-- Refresh
----------------------------------------------------------

function Navigation:Refresh()

	if self.CurrentPage then

		self.CurrentPage.CanvasPosition =
			Vector2.new(0,0)

	end

end

----------------------------------------------------------
-- Get Current Page
----------------------------------------------------------

function Navigation:GetCurrentPage()

	return self.CurrentPage

end

----------------------------------------------------------

return Navigation
