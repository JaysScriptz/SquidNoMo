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
    Game = "Glass Bridge",
    Id = "mapped.games.glass_bridge.antifall",
    Name = "Anti Fall",
    Description = "Keeps the latest grounded bridge position and attempts a non-teleport recovery when a fall begins.",
    Handler = "FallRecovery",
    DropDistance = 14,
    FallVelocity = 55,
    RecoveryPriority = 88,
    Interval = 0.12,
    IdleInterval = 0.55,
})
