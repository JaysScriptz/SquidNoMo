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
    Game = "Marbles",
    Id = "mapped.games.marbles.recoveryassist",
    Name = "Recovery Assist",
    Description = "Keeps the player near the position where the feature was enabled so missed throws do not pull them away from the aiming area.",
    Handler = "PositionKeeper",
    MaxDistance = 9,
    MovementPriority = 28,
    Interval = 0.3,
    IdleInterval = 0.8,
})
