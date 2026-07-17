local Config = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
))()

print("LOADER STARTED")

local Loader = {}

local function Load(Path)
    print("Loading:", Path)

    local Source = game:HttpGet(
        Config.Repository .. Path
    )

    local Module = loadstring(Source)()

    print("Loaded:", Path)

    return Module
end

----------------------------------------------------
-- Core
----------------------------------------------------

Loader.Theme = Load("Core/Theme.lua")

----------------------------------------------------
-- Temporary Home
----------------------------------------------------

Loader.Home = {
    Load = function()
        print("HOME FUNCTION")

        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "SquidNoMo",
                Text = "Theme Loaded Successfully",
                Duration = 5
            })
        end)
    end
}

return Loader
