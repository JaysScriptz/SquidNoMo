--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
--// Loader.lua
--//========================================================--

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local function Load(Path)
    if Config.Debug then
        print("[SquidNoMo Loader] " .. Path)
    end

    local Url = Config.Repository .. Path
    local Source = game:HttpGet(Url)
    local Chunk, CompileError = loadstring(Source)

    if not Chunk then
        error(string.format("[SquidNoMo Loader] Compile failed for %s: %s", Path, tostring(CompileError)))
    end

    local Success, Result = pcall(Chunk)

    if not Success then
        error(string.format("[SquidNoMo Loader] Execution failed for %s: %s", Path, tostring(Result)))
    end

    return Result
end

local Loader = {
    Config = Config,
    Features = {},
}

----------------------------------------------------------
-- Core
----------------------------------------------------------

Loader.Theme = Load("Core/Theme.lua")
Loader.Icons = Load("Core/Icons.lua")
Loader.Components = Load("Core/Components.lua")
Loader.Navigation = Load("Core/Navigation.lua")
Loader.Utilities = Load("Core/Utilities.lua")
Loader.Notifications = Load("Core/Notifications.lua")
Loader.FeatureRegistry = Load("Core/FeatureRegistry.lua")
Loader.RuntimeStats = Load("Core/RuntimeStats.lua")

----------------------------------------------------------
-- Existing feature layer
----------------------------------------------------------

Loader.FeatureManager = Load("Features/FeatureManager.lua")

local FeaturesLoaded, FeaturesOrError = pcall(function()
    return Loader.FeatureManager:Initialize(Loader)
end)

if FeaturesLoaded then
    Loader.Features = FeaturesOrError or {}
    if Config.Debug then
        print("[SquidNoMo Loader] Existing features initialized")
    end
else
    warn("[SquidNoMo Loader] Feature initialization failed:", FeaturesOrError)
    Loader.Features = {}
end

----------------------------------------------------------
-- App and pages
----------------------------------------------------------

Loader.App = Load("Core/App.lua")

Loader.Home = Load("Modules/Home.lua")
Loader.Games = Load("Modules/Games.lua")
Loader.Players = Load("Modules/Players.lua")
Loader.Guards = Load("Modules/Guards.lua")
Loader.Detective = Load("Modules/Detective.lua")
Loader.Farming = Load("Modules/Farming.lua")
Loader.UI = Load("Modules/UI.lua")
Loader.Settings = Load("Modules/Settings.lua")

Loader.HomeHero = Load("Modules/Home/Hero.lua")
Loader.HomeFeatureStats = Load("Modules/Home/FeatureStats.lua")
Loader.HomeStatusPanels = Load("Modules/Home/StatusPanels.lua")

----------------------------------------------------------
-- Launch
----------------------------------------------------------

Loader.App:Build(Loader)

return Loader
