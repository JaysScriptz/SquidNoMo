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
    Id = "mapped.games.sky_squid.antifall",
    Name = "Anti Fall",
    Description = "Keeps the latest grounded platform position and attempts a non-teleport recovery when a fall begins.",
    Handler = "FallRecovery",
    DropDistance = 12,
    FallVelocity = 52,
    RecoveryPriority = 82,
    Interval = 0.12,
    IdleInterval = 0.55,
})
