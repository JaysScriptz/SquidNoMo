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
    Game = "Rebellion",
    Id = "mapped.games.rebellion.guardcombat",
    Name = "Guard Combat",
    Description = "Targets confirmed guard or soldier characters and activates an equipped combat tool at a controlled rate.",
    Handler = "ToolAura",
    PlayerTokens = {"guard", "staff", "soldier"},
    TargetTokens = {"guard", "staff", "soldier"},
    IncludeNPCs = true,
    ToolTokens = {"gun", "rifle", "pistol", "bat", "weapon"},
    Range = 16,
    FaceTarget = true,
    ActionCooldown = 0.28,
    ActionPriority = 72,
    Interval = 0.2,
    IdleInterval = 0.75,
})
