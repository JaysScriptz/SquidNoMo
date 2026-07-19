--// SquidNoMo entry point

print("[SquidNoMo] Starting v0.5.1")

local LoaderSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
)

local Loader = loadstring(LoaderSource)()

print("[SquidNoMo] Loader executed")

return Loader
