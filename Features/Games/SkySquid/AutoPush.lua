local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table" and Environment.__SquidNoMoBuildManifest or {}
local Runtime = Environment.__SquidNoMoGameRuntime
if type(Runtime) ~= "table"
    or tostring(Runtime.Revision) ~= tostring(Manifest.GameRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo game runtime is unavailable; deploy and execute the complete current build")
end


return Runtime:CreateFeature({
    Game = "Sky Squid",
    Id = "mapped.games.sky_squid.autopush",
    Name = "Auto Push",
    Description = "Uses an equipped push or shove tool only when a living opponent is within range.",
    Handler = "ToolAura",
    ToolTokens = {"push", "shove"},
    Range = 12,
    FaceTarget = true,
    ActionCooldown = 0.3,
    ActionPriority = 76,
    Interval = 0.2,
    IdleInterval = 0.7,
})
