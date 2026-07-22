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
    Game = "Hide & Seek",
    Id = "mapped.games.hide_seek.autoswing",
    Name = "Auto Swing",
    Description = "For Seekers, faces a nearby opponent and activates an equipped melee tool at a controlled rate.",
    Handler = "ToolAura",
    Role = "Seeker",
    ToolTokens = {"knife", "blade", "bat", "weapon"},
    Range = 10,
    FaceTarget = true,
    ActionCooldown = 0.28,
    ActionPriority = 72,
    Interval = 0.18,
    IdleInterval = 0.7,
    WaitingMessage = "Waiting for a melee tool and nearby opponent",
})
