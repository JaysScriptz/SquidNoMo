print("MAIN VERSION 7")

local ConfigSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Config.lua"
)

local Config = loadstring(ConfigSource)()

print("CONFIG LOADED")

local LoaderSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
)

print("LOADER DOWNLOADED")

local Loader = loadstring(LoaderSource)()

print("LOADER EXECUTED")

Loader.Home.Load()

print("HOME FINISHED")
