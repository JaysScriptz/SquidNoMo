--//========================================================
--// SquidNoMo Beta 5.0
--// Loader.lua
--//========================================================

local Loader = {}

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local BASE = Config.Repository

local function LoadModule(Path)
    local URL = BASE .. Path

    Config.Print("Loading:", Path)

    local Success, Result = Config.Try(Path, function()
        return loadstring(game:HttpGet(URL))()
    end)

    if not Success then
        error("Failed to load " .. Path)
    end

    return Result
end

------------------------------------------------------------
-- Core Modules
------------------------------------------------------------

Loader.Theme = LoadModule("Core/Theme.lua")
Loader.Components = LoadModule("Core/Components.lua")
Loader.Navigation = LoadModule("Core/Navigation.lua")
Loader.Notifications = LoadModule("Core/Notifications.lua")
Loader.Utilities = LoadModule("Core/Utilities.lua")

------------------------------------------------------------
-- Page Modules
------------------------------------------------------------

Loader.Home = LoadModule("Modules/Home.lua")

return Loader
