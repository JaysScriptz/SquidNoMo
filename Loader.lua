--//========================================================
--// SquidNoMo Beta 5.0
--// Loader.lua
--//========================================================

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local Loader = {}

local function Load(Path)
    print("[Loader] Loading: " .. Path)

    local Source = game:HttpGet(Config.Repository .. Path)

    local Module = loadstring(Source)()

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Loaded",
            Text = Path,
            Duration = 2
        })
    end)

    print("[Loader] Loaded: " .. Path)

    return Module
end
----------------------------------------------------
-- Core Modules
----------------------------------------------------

Loader.Theme = Load("Core/Theme.lua")
Loader.Components = Load("Core/Components.lua")
Loader.Utilities = Load("Core/Utilities.lua")
Loader.Notifications = Load("Core/Notifications.lua")
Loader.Navigation = Load("Core/Navigation.lua")

--------------------------------------------------
-- Page Modules
--------------------------------------------------

Loader.Home = Load("Modules/Home.lua")

--------------------------------------------------
-- Start Application
--------------------------------------------------

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SquidNoMo",
        Text = "Launching...",
        Duration = 3
    })
end)

print("[Loader] Starting Home...")

if Loader.Home then
    if type(Loader.Home) == "table" then
        if Loader.Home.Load then
            Loader.Home.Load()
        elseif Loader.Home.Init then
            Loader.Home.Init()
        end
    elseif type(Loader.Home) == "function" then
        Loader.Home()
    end
end

print("[Loader] Finished.")

return Loader
