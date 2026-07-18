--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Loader.lua
--//========================================================--

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local function Load(Path)

    print("[Loader] "..Path)

    local Source =
        game:HttpGet(
            Config.Repository .. Path
        )

    return loadstring(Source)()

end

----------------------------------------------------------
-- Core
----------------------------------------------------------

local Loader = {}
Loader.Config = Config

Loader.Theme         = Load("Core/Theme.lua")
Loader.Components    = Load("Core/Components.lua")
Loader.Navigation    = Load("Core/Navigation.lua")
Loader.Utilities     = Load("Core/Utilities.lua")
Loader.Notifications = Load("Core/Notifications.lua")

----------------------------------------------------------
-- App
----------------------------------------------------------

Loader.App = Load("Core/App.lua")

----------------------------------------------------------
-- Pages
----------------------------------------------------------

Loader.Home = Load("Modules/Home.lua")
Loader.Players = Load("Modules/Players.lua")

----------------------------------------------------------
-- Home Modules
----------------------------------------------------------

Loader.HeroBanner = Load("Modules/Home/HeroBanner.lua")
Loader.FeatureGroups = Load("Modules/Home/FeatureGroups.lua")
Loader.ServerStatus = Load("Modules/Home/ServerStatus.lua")
Loader.NOMOAI = Load("Modules/Home/NOMOAI.lua")
Loader.SupportDevelopment = Load("Modules/Home/SupportDevelopment.lua")
Loader.DevelopmentGoal = Load("Modules/Home/DevelopmentGoal.lua")
Loader.Supporters = Load("Modules/Home/Supporters.lua")
Loader.ImportantNotice = Load("Modules/Home/ImportantNotice.lua")
Loader.Footer = Load("Modules/Home/Footer.lua")

----------------------------------------------------------
-- Launch
----------------------------------------------------------

Loader.App:Build(Loader)

return Loader
