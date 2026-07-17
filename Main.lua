--//========================================================
--// SquidNoMo Beta 5.0
--// Main.lua
--//========================================================

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

Config.Print("Starting SquidNoMo Beta 5.0")

local Loader = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
))()

------------------------------------------------------------
-- Application
------------------------------------------------------------

local App = {}

App.Version = "Beta 5.0"

App.Theme = Loader.Theme

App.Components = Loader.Components

App.Navigation = Loader.Navigation

App.Notifications = Loader.Notifications

App.Utilities = Loader.Utilities

------------------------------------------------------------
-- Register Pages
------------------------------------------------------------

App.Pages = {

	Home = Loader.Home,

}

------------------------------------------------------------
-- Open Page
------------------------------------------------------------

function App:OpenPage(PageName)

	local Page = self.Pages[PageName]

	if not Page then

		Config.Error("Page not found: "..tostring(PageName))

		return

	end

	Config.Print("Opening "..PageName)

	Page:Load(self)

end

------------------------------------------------------------
-- Start
------------------------------------------------------------

Config.Print("Launching Home")

App:OpenPage("Home")

Config.Print("Startup Complete")

return App
