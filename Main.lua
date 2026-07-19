--// SquidNoMo entry point

print("[SquidNoMo] Starting v0.5.0 Beta")

local LoaderSource = game:HttpGet(
    "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
)

local LoaderChunk, CompileError = loadstring(LoaderSource)

if not LoaderChunk then
    error("[SquidNoMo] Loader compile failed: " .. tostring(CompileError))
end

local Success, LoaderOrError = pcall(LoaderChunk)

if not Success then
    error("[SquidNoMo] Loader failed: " .. tostring(LoaderOrError))
end

print("[SquidNoMo] Dashboard ready")
return LoaderOrError
