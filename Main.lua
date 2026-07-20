--// SquidNoMo entry point

local BUILD_VERSION = "v0.6.2-beta"
local BUILD_TOKEN = string.gsub(BUILD_VERSION, "[^%w_%-]", "_")

print("[SquidNoMo] Starting " .. BUILD_VERSION)

local LoaderSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
        .. "?squidnomo_build="
        .. BUILD_TOKEN
)

local Loader = loadstring(LoaderSource)()

print("[SquidNoMo] Loader executed")

return Loader
