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
    Game = "Fight Nights",
    Id = "mapped.games.fight_nights.brawlevasion",
    Name = "Brawl Evasion",
    Description = "Moves away from the nearest living opponent while preserving shared movement ownership.",
    Handler = "Evasion",
    Range = 24,
    EvadeDistance = 20,
    MovementPriority = 76,
    Interval = 0.2,
    IdleInterval = 0.7,
})
