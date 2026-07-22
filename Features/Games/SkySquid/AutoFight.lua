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
    Id = "mapped.games.sky_squid.autofight",
    Name = "Auto Fight",
    Description = "Faces the nearest living opponent and activates an equipped combat tool at a controlled rate.",
    Handler = "ToolAura",
    ToolTokens = {"knife", "pole", "bat", "weapon", "push"},
    Range = 11,
    FaceTarget = true,
    ActionCooldown = 0.27,
    ActionPriority = 62,
    Interval = 0.18,
    IdleInterval = 0.7,
})
