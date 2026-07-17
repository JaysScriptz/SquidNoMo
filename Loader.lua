--//========================================================
--// SquidNoMo Beta 5.0
--// Loader.lua
--//========================================================

local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

local Loader = {}

local function Load(Path)
    print("[Loader] Loading:", Path)

    local Source = game:HttpGet(Config.Repository .. Path)

    local Module = loadstring(Source)()

    print("[Loader] Loaded:", Path)

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

----------------------------------------------------
-- Page Modules
----------------------------------------------------

Loader.Home = {
    Load = function()

        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title = "SquidNoMo",
                Text = "Core Modules Loaded",
                Duration = 5
            })
        end)

        print("[Loader] Home Loaded")

    end
}

return Loader
