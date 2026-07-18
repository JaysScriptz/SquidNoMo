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
-- NEW
----------------------------------------------------------

Loader.App = Load("Core/App.lua")
--Loader.Features = Load("Features/FeatureManager.lua")

-----------------------------------------------------------
-- Pages
----------------------------------------------------------

Loader.Home    = Load("Modules/Home.lua")
Loader.Players = Load("Modules/Players.lua")

----------------------------------------------------------
-- Launch
----------------------------------------------------------

Loader.Features:Initialize(Loader)

Loader.App:Build(Loader)



return Loader
