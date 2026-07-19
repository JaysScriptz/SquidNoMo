--// SquidNoMo entry point

print("[SquidNoMo] Starting Beta 5.0")

local LoaderSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
)

local Loader = loadstring(LoaderSource)()

print("[SquidNoMo] Loader executed")

return Loader
