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
    Id = "mapped.games.glass_bridge.autoreset",
    Name = "Auto Reset",
    Description = "Attempts to steer the character back toward the last grounded bridge point without teleporting.",
    Handler = "FallRecovery",
    DropDistance = 8,
    FallVelocity = 38,
    RecoveryPriority = 72,
    Interval = 0.12,
    IdleInterval = 0.55,
})
