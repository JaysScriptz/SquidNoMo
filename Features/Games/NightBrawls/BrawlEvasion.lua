local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or Runtime.Revision ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo verified feature runtime is unavailable; execute the complete current build")
end

return Runtime:CreateFeature({
    ExpectedGame = "Fight Nights",
    Id = "mapped.games.fight_nights.brawlevasion",
    Name = "Brawl Evasion",
    Description = "Keeps distance from nearby attackers and dangerous positions.",
    Kind = "Evasion",
    Range = 24,
    EvadeDistance = 20,
    Interval = 0.24,
    MovementPriority = 75,
})
