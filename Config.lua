--//========================================================
--// SquidNoMo Beta 5.0
--// Config.lua
--//========================================================

local Config = {}

------------------------------------------------------------
-- Repository
------------------------------------------------------------

Config.Repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"

------------------------------------------------------------
-- Debug
------------------------------------------------------------

Config.Debug = true

------------------------------------------------------------
-- Debug Functions
------------------------------------------------------------

function Config.Print(...)
    if Config.Debug then
        print("[SquidNoMo]", ...)
    end
end

function Config.Warn(...)
    if Config.Debug then
        warn("[SquidNoMo]", ...)
    end
end

function Config.Error(...)
    warn("[SquidNoMo ERROR]", ...)
end

------------------------------------------------------------
-- Safe Execute
------------------------------------------------------------

function Config.Try(Name, Callback)
    local Success, Result = pcall(Callback)

    if not Success then
        Config.Error(Name)
        Config.Error(Result)
    else
        Config.Print(Name .. " Loaded")
    end

    return Success, Result
end

return Config
